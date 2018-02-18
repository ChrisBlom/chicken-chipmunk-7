(import-for-syntax bind-translator matchable extras)
(use matchable)

(begin-for-syntax

 (import chicken scheme matchable bind-translator foreign extras)

 (define (extract-type type)
   (match type
     [('struct x) (extract-type x)]
     [('const x) (extract-type x)]
     [other other]))

 (define (struct-by-value? type)
   (match (extract-type type)
     ["cpBB"              '(f64vector . 4)]
     ["cpVect"            '(f64vector . 2)]
     ["cpMat2x2"          '(f64vector . 4)]
     ["cpShapeFilter"     '(f64vector . 3)]
     ["cpTransform"       '(f64vector . 6)]
     ["cpSpaceDebugColor" '(f64vector . 4)]
     ["cpShapeFilter"     '(f64vector . 3)]
     [other #f]))

 (define (convert-type argument-type)
   (let ([v (struct-by-value? argument-type)])
     (if v (car v) #f)))

 (define (convert-return-type type)
   (let ([converted (convert-type type)])
     (match converted
       [#f type]
       ['f64vector 'void]
       [other converted])))

 (define (convert-args type-var-pairs)
   (map (lambda (type+var) (list (or (convert-type (car type+var))
				     (car type+var))
				 (cadr type+var)))
	type-var-pairs))

 (define (walk f x)
   (if (list? x)
       (map (cut walk f <>) x)
       (f x)))

 ;;derefence all occurences of argument variables that have a type that should be converted
 (define (dereference-in-body body types+args)
   (let* ([args-to-deref (map second (filter (compose convert-type first) types+args))]
	  [arg->type (map (lambda (x) (cons (second x) (first x))) types+args)]
	  [maybe-deref (lambda (v) (if (member v args-to-deref)
				       `(deref ,(conc "((" (extract-type (alist-ref v arg->type)) "*)"  v ")"))
				       v))])
     (walk maybe-deref body)))

 (define (bind-returning-struct-by-value return-type args body rename)
   (let ([argnames (append-map cdr args)] ; drop type
	 [foreign-fn (bind-foreign-lambda*
		      `(foreign-lambda*
			   ;; return void instead of the struct
			   void
			   ;; include extra '_return_val' argument to assign the foreign function's return value to"
			   ( (f64vector _return_val) ,@args)
			 ;; assign the foreign functions return value to '_return_val' and don't return anything:
			 (stmt
			  ;; cast '_return_val' value to a pointer
			  (= ,(string-append (extract-type return-type) "* return_ptr_") ,(string-append "(" (extract-type return-type)"*) _return_val"))
			  ;; call foreign function and assign result to value of 'return_ptr_', which also assigns it to '_return_val'
			  (= "*return_ptr_" ,body))) rename)])
     `(lambda ,argnames
	;; init _return_val to a f64vector with the appropriate size
	(,(rename 'let) ([_return_val (make-f64vector ,(cdr (struct-by-value? return-type)) 0)])
	 ;; pass the '_return_val' argument and the original arguments to the modified fn
	 (,foreign-fn ,@(cons '_return_val argnames))
	 ;; return '_return_val' f64vector that holds the result of the bound functiong
	 _return_val))))

 (define (skip? name)
   (when (string? name)
     (or ;; skip low level constructors
      (string-suffix? "Raw" name)
      (string-suffix? "Alloc" name)
      (string-suffix? "Init" name)
      (string-suffix? "Destroy" name))))

 (define function-names '()))

(define-for-syntax chipmunk#function-names (list))

;; workaround to adapt functions that pass by value
;; Chicken Scheme cannot bind functions that receive structs by value,
;; as a workaround we pass f64vectors instead and replace and dereference all uses
;; of the modified argument
(define-for-syntax (chipmunk#struct-by-value-transformer foreign rename)
  #;(pretty-print `(before ,foreign))
  (match foreign
    [(foreign-lambda* return-type args body)
     (let* ([name (first body)]
	    [foreign-fn (cond

			 ;; TODO is it possible to skip some functions?
			 ;; [(skip? name) #f]

			 ;; Chicken Scheme also cannot bind foreign functions that return a struct by value.
			 ;; As a workaround, the body is modified to assign the foreign function's return value to
			 ;; a newly created f64vector, which is then returned
			 [(struct-by-value? return-type)
			  (bind-returning-struct-by-value return-type (convert-args args) (dereference-in-body body args) rename)]

			 ;; Compatible return type: only convert the arguments and body
			 [else
			  (bind-foreign-lambda*
			   `(foreign-lambda* ,return-type ,(convert-args args) ,(dereference-in-body body args))
			   rename)])])

       ;; export fn names for getter and setter generation
       (when (and name (string? name)) #;(and name (not (skip? name)))
	 ;;#;(pretty-print `(name ,name))
	 (set! function-names (cons (cons name foreign-fn) function-names)))

       #;(pretty-print `(after ,foreign-fn))

       foreign-fn)]))
