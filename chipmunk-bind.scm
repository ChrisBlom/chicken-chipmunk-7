(import chicken bind foreign srfi-4)

(include "struct-by-value-transformer.scm")

;; dummy declaration to avoid unbound identifier error
(define struct-by-value-transformer #f)

;; these headers are modified for compatibility with chicken bind
(bind-include-path "./include")

;; strip "cp.." prefix
(bind-rename/pattern "^cp" "")

(bind-options default-renaming: ""
	      foreign-transformer: struct-by-value-transformer
	      export-constants: true)

;;;; Override definitions

(bind "#define CP_EXPORT")
(bind "#define CP_PI 3.14159265358979")

;; REVIEW what type to use?
;; chicken-bind doesn't support the default uintptr_t
(bind "#define CP_GROUP_TYPE unsigned int")
(bind "#define CP_HASH_VALUE_TYPE unsigned int")
(bind "#define CP_COLLISION_TYPE_TYPE unsigned int")

(define uint
  (foreign-lambda* unsigned-int ((int x))
    "unsigned int n = x;
     C_return(n);") )

(bind-file "include/chipmunk.h")
