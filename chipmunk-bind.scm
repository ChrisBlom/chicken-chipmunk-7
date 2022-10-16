(import chicken.base)
(import chicken.syntax)
(import chicken.foreign)
(import chicken.string)
(import bind)

(import-for-syntax bind-translator)
(import-for-syntax regex)
(import-for-syntax matchable)
(import-for-syntax chicken.pretty-print)
(import-for-syntax chicken.string)
(import-for-syntax chicken.sort)
(import-for-syntax srfi-1)

(begin-for-syntax
 (print "===== compile-time")
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
       [#f         type]
       ['f64vector 'void]
       [other      converted])))

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
					;(print `('dereference-in-body ,body ,types+args))
   (let* ([args-to-deref (map second (filter (compose convert-type first) types+args))]
	  [arg->type (map (lambda (x) (cons (second x) (first x))) types+args)]
	  [maybe-deref (lambda (v) (if (member v args-to-deref)
				       `(deref ,(conc "((" (extract-type (alist-ref v arg->type)) "*)"  v ")"))
				       v))]
	  [modified-body (walk maybe-deref body)])
					;(print `('dereference-in-body-out ,modified-body))
     modified-body))

 (define (bind-returning-struct-by-value return-type args body rename)
   (let ([argnames (append-map cdr args)] ; drop type
	 [foreign-fn (bind-foreign-lambda*
		      `(foreign-lambda*
			   ;; return void instead of the struct
			   void
			   ;; include extra '_return_val' argument to assign the foreign function's return value to"
			   ( (f64vector _return_val) ,@args) ;; < TODO
			 ;; assign the foreign functions return value to '_return_val' and don't return anything:
			 (stmt
			  ;; cast '_return_val' value to a pointer
			  (= ,(string-append (extract-type return-type) "* return_ptr_") ;
			     ,(string-append "(" (extract-type return-type)"*) _return_val"))
			  ;; call foreign function and assign result to value of 'return_ptr_', which also assigns it to '_return_val'
			  (= "*return_ptr_" ,body)
			  )
			 )

		      rename)])
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

 (define function-names '())

 (define function-names (list))

 ;; workaround to adapt functions that pass by value
 ;; Chicken Scheme cannot bind functions that receive structs by value,
 ;; as a workaround we pass f64vectors instead and replace and dereference all uses
 ;; of the modified argument

 (print "M" (current-module))

 (define (a#struct-by-value-transformer foreign rename)
					;(pretty-print `(before ,foreign))
   (match foreign
     [
      (foreign-lambda* return-type args body)
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

					;(pretty-print `(after ,foreign-fn))

	foreign-fn)]))

 (print "M" a#struct-by-value-transformer)
 )

;; these headers are modified for compatibility with chicken bind
(bind-include-path "./include")

;; strip "cp.." prefix
(bind-rename/pattern "^cp" "")

(bind-options default-renaming: ""
  	      foreign-transformer: (lambda (e r) (a#struct-by-value-transformer e r))
  	      export-constants: true
  	      )

;;;; Override definitions

(bind "#define CP_EXPORT")
(bind "#define CP_PI 3.14159265358979")

;; REVIEW what type to use?
;; chicken-bind doesn't support the default uintptr_t
(bind "#define CP_GROUP_TYPE unsigned int")
(bind "#define CP__TYPE unsigned int")
(bind "#define CP_HASH_VALUE_TYPE unsigned int")
(bind "#define CP_COLLISION_TYPE_TYPE unsigned int")
(bind "#define CP_SPACE_DISABLE_DEBUG_API true")

(define uint
  (foreign-lambda* unsigned-int ((int x))
    "unsigned int n = x;
     C_return(n);") )

(bind-file "include/chipmunk.h")

;;;; Process the function-names collected by the struct-by-value transformer and
;;;; generate chipmunk-getter-with-setters.scm based on the function names

(define-for-syntax usual-naming-transform
  (let ()
    (define (downcase-string str) ; so we don't have to use srfi-13
      (let ([s2 (string-copy str)]
	    [n (string-length str)] )
	(do ([i 0 (+ i 1)])
	    ((>= i n) s2)
	  (string-set! s2 i (char-downcase (string-ref str i))) ) ) )
    (lambda (m)
      (downcase-string
       (string-translate
	(string-substitute "([a-z])([A-Z])" "\\1-\\2" m #t)
	"_" "-") ) ) ) )

(begin-for-syntax

 (define-syntax define-attr-access
   (syntax-rules ()
     ((define-attr-access attr-list class attr op)
					;(pretty-print `(expr ,class ,attr ,op)) ; ; ;
      (if (member (list class attr 'set) attr-list) ;; has a setter?
	  `(define ,(symbol-append class '- attr)
	     (getter-with-setter
	      ,(symbol-append class '-get- attr)
	      ,(symbol-append class '-set- attr)))
	  `(define ,(symbol-append class '- attr)
	     ,(symbol-append class '-get- attr))))))

 (define-syntax define-varargs
   (syntax-rules ()
     ((define-attr-access attr-list class attr op)
      `(define (,(symbol-append class '- op '- attr 's) ,class . ,(symbol-append attr 's))
	 (for-each (lambda (,attr) (,(symbol-append class '- op '- attr) ,class ,attr)) ,(symbol-append attr 's))
	 ,class
	 ))))

 (define-syntax define-predicate
   (syntax-rules ()
     ((define-attr-access attr-list class attr op)
      `(define ,(symbol-append class '- attr '?) ,(symbol-append class '- op '- attr)
	 ))))

 (define (extract-name def)
   (pretty-print def)
   (if (symbol? (cadr def))
       (cadr def)
       (caadr def)))

 (define (symbol-list> a b)
   (cond
    [(and (null-list? a) (not (null-list? b))) #f]
    [(and (not (null-list? a)) (null-list? b)) #t]
    [(eq? (car a) (car b)) (symbol-list> (cdr a) (cdr b))]
    [(string> (symbol->string (car a)) (symbol->string (car b)))]))

 (let* ([attr-list (append-map
		    (lambda (x)
		      (if (string? (car x))
			  (match (string-match (regexp "cp([A-Z][A-Za-z]+)(Is|Get|Set|Add|Remove)([A-Za-z]+)") (car x))
			    [(m class op attribute)
			     (list (map (compose string->symbol usual-naming-transform) (list class attribute op)))]
			    [ow '()])
			  '()))
		    function-names)]
	[expanded (sort (append-map (lambda (x) (apply (lambda (class attr op)
							 (cond
							  [(equal? op 'get)    (list (define-attr-access attr-list class attr op))]
							  [(equal? op 'add)    (list (define-varargs attr-list class attr op))]
							  [(equal? op 'remove) (list (define-varargs attr-list class attr op))]
							  [(equal? op 'is)     (list (define-predicate attr-list class attr op))]
							  ['()]))
						       x))
				    attr-list)
			(lambda (x y) (string<? (symbol->string (extract-name x))
					       (symbol->string (extract-name y)))))])

   (with-output-to-file "chipmunk-getter-with-setters.scm"
     (lambda ()
       (for-each pretty-print expanded)))))
;;)
