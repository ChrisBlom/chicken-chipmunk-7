(import-for-syntax bind-translator matchable)
(begin-for-syntax
 (import chicken scheme matchable bind-translator foreign)


(define (extract-type type)
  (match type
    [('struct x) (extract-type x)]
    [('const x) (extract-type x)]
    [other other]))

(define (convert-arg-type? type)
  (match type
    [('const c) (convert-arg-type? c) ]
    [('struct x) (convert-arg-type? x )  ]
    ["cpVect" 'f64vector]
    ["cpBB" 'f64vector]
    ["cpTransform" 'f64vector]
    ["cpMat2x2" 'f64vector]
    ["uintptr_t" 'long]
    [other #f]))

(define (returns-struct-by-value? type)
  (match type
    [('const c) (returns-struct-by-value? c) ]
    [('struct x) (returns-struct-by-value? x)  ]
    ["cpVect" #t]
    ["cpBB" #t]
    ["cpTransform" #t]
    ["cpMat2x2" #t]
    ["uintptr_t" #f] ;; <-
    [other #f]))

(define (convert-args? args)
  (any convert-arg-type? (map car args)))

(define (convert-ret-type type)
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

(define (convert-body body args)
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
		       (loop t))])))


  )

;; workaround to adapt functions that pass by value
;; Chicken Scheme cannot bind function that receive structs by value,
;; as a workaround we pass f64vector instead and replaces all uses with derefences
(define struct-by-value-transformer (void))
(define-for-syntax (chipmunk#struct-by-value-transformer foreign rename)
  (match foreign
    [(foreign-lambda* return-type args body)
     (if (returns-struct-by-value? return-type)
	 ;; Chicken Scheme also cannot bind foreign functions that return a struct by value.
	 ;; As a workaround, the body is modified to assign the foreign function's return value to
	 ;; a newly created f64vector, which is then returned
	 (let ([argnames (apply append (map cdr args))]
	       [bound-foreign (bind-foreign-lambda*
			       `(foreign-lambda*
				    ;; return void instead of the struct:
				    void
				    ;; include extra 'collect' argument to collect the foreign function's return value"
				    ( (f64vector collect) ,@(convert-args args))
				  ;; assign the foreign functions return value to 'collect', don't return anything:
				  (stmt
				   ;; cast 'collect' value to a pointer
				   (= ,(string-append (extract-type return-type) "* collect_ptr_") ,(string-append "(" (extract-type return-type)"*) collect"))
				   ;; call foreign function and assign result to value of 'collect_ptr_', which also assigns it to 'collect'
				   (= "*collect_ptr_" ,(convert-body body args) )))
			       rename)])
	   ;; provide the 'collect' argument, the foreign function's return value will be assign it result to it,
	   ;; so we can return it afterward
	   `(lambda ,argnames
	      (,(rename 'let) ([collect (make-f64vector ,(match (extract-type return-type) ; struct sizes
							   ["cpBB" 4]
							   ["cpVect" 2]
							   ["cpMat2x2" 4]
							   ["cpTransform" 6])
							0)])
	       ;; pass the 'collect' argument + original arguments to modified binding
	       (,bound-foreign ,@(cons 'collect argnames))
	       ;; return 'collect'
	       collect)))

	 ;; bind the foreign function with converted return type, args and body
	 (bind-foreign-lambda*
	  `(foreign-lambda*
	       ,(convert-ret-type return-type)
	       ,(convert-args args)
	     ,(convert-body body args))
	  rename))])))
