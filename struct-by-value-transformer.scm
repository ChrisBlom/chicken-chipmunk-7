(import-for-syntax bind-translator matchable extras)
(begin-for-syntax
 (import chicken scheme matchable bind-translator foreign extras)

(define (extract-type type)
  (match type
    [('struct x) (extract-type x)]
    [('const x) (extract-type x)]
    [other other]))

(define (returns-struct-by-value? type)
  (match type
    [('const c) (returns-struct-by-value? c) ]
    [('struct x) (returns-struct-by-value? x)  ]
    ["cpVect" #t]
    ["cpBB" #t]
    ["cpTransform" #t]
    ["cpMat2x2" #t]
    ["cpShapeFilter" #t]
    ["cpSpaceDebugColor" #t]
    ["cpShapeFilter" #t]
    [other #f]))

(define (struct-by-value-size type)
  (match (extract-type type) ; struct sizes
    ["cpBB" 4]
    ["cpVect" 2]
    ["cpMat2x2" 4]
    ["cpShapeFilter" 3]
    ["cpTransform" 6]
    ["cpSpaceDebugColor" 4]
    ["cpShapeFilter" 3]))

(define (convert-arg-type? type)
  (match type
    [('const c) (convert-arg-type? c) ]
    [('struct x) (convert-arg-type? x )  ]
    ["cpVect" 'f64vector]
    ["cpBB" 'f64vector]
    ["cpTransform" 'f64vector]
    ["cpMat2x2" 'f64vector]
    ["cpSpaceDebugColor" 'f64vector]
    ["cpShapeFilter" 'f64vector] ;; TODO <- this is not the right type! use uint32vector
    [other #f]))

(define (convert-return-type type)
  (let ([converted (convert-arg-type? type)])
    (match converted
      [#f type]
      ['f64vector 'void]
      [other converted])))

(define (convert-args type-var-pairs)
  (map (lambda (type+var) (list (or (convert-arg-type? (car type+var))
			       (car type+var))
			   (cadr type+var)))
       type-var-pairs))

(define (dereference-in-body body args)
  (let* ([conv-args (apply append (map cdr (filter (compose convert-arg-type? car) args)))]
	 [arg->type-alist (fold (lambda (arg-pair acc)
				  (let* ([var (second arg-pair)]
					 [type (extract-type (first arg-pair))])
				    (alist-cons var type acc)))
				'()
				args)]
	 [arg->type (lambda (arg) (alist-ref arg arg->type-alist))])
    (let loop ([x body])
      (match x
	[() '()]
	[(h . t) (cons (if (member h conv-args)
			   `(deref ,(conc "((" (arg->type h) "*)"  h ")") )
			   h)
		       (loop t))]))))


(define function-names '())

;; convert c code to assign result to a return value
(define (struct-by-ref-body return-type args body)
  `(foreign-lambda*
       ;; return void instead of the struct:
       void
       ;; include extra '_return_val' argument to collect the foreign function's return value"
       ( (f64vector _return_val) ,@(convert-args args))
     ;; assign the foreign functions return value to '_return_val' and don't return anything:
     (stmt
      ;; cast '_return_val' value to a pointer
      (= ,(string-append (extract-type return-type) "* return_ptr_") ,(string-append "(" (extract-type return-type)"*) _return_val"))
      ;; call foreign function and assign result to value of 'return_ptr_', which also assigns it to '_return_val'
      (= "*return_ptr_" ,(dereference-in-body body args)))))

(define (return-struct-by-value return-type args body rename)
  (let ([argnames (append-map cdr args)] ; drop type
	[bound-foreign (bind-foreign-lambda* (struct-by-ref-body return-type args body) rename)])
    ;; provide the '_return_val' argument, the foreign function's return value will be assign it result to it,
    ;; so we can return it afterward
    `(lambda ,argnames
       ;; TODO let collect constructor depend on type
       (,(rename 'let) ([_return_val (make-f64vector ,(struct-by-value-size return-type) 0)])
	;; pass the '_return_val' argument + original arguments to modified binding
	(,bound-foreign ,@(cons '_return_val argnames))
	;; return '_return_val' f64vector
	_return_val))))


;; workaround to adapt functions that pass by value
;; Chicken Scheme cannot bind function that receive structs by value,
;; as a workaround we pass f64vector instead and replaces all uses with derefences
;(define struct-by-value-transformer (void))
)

(define-for-syntax chipmunk#function-names (list))

(define-for-syntax (chipmunk#struct-by-value-transformer foreign rename)
  ;;(display "\n-- BEFORE : ---")q
;  (pretty-print (string-match (regexp "cp([A-Z][A-Za-z]+)(Get|Set)([A-Za-z]+)") "cpRatchetJointGetPhase"))
  ;(pretty-print foreign)
  ;(newline)
  (match foreign
    [(foreign-lambda* return-type args body)
     (let ([bound (if (returns-struct-by-value? return-type)
		       ;; Chicken Scheme also cannot bind foreign functions that return a struct by value.
		       ;; As a workaround, the body is modified to assign the foreign function's return value to
		       ;; a newly created f64vector, which is then returned
		       (return-struct-by-value return-type args body rename)
		       ;; Compatible return type:
		       ;; only convert the arguments and body
		       (bind-foreign-lambda*
			`(foreign-lambda*
			     ,(convert-return-type return-type)
			     ,(convert-args args)
			   ,(dereference-in-body body args))
			rename))])
       (let ([name (first (car (cdddr foreign)))])
	 ;(pretty-print `(name ,name))
	 (when name (set! function-names (cons (cons name bound) function-names)))
	 bound))]))
