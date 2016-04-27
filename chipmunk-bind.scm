(import chicken bind foreign srfi-4)

(include "struct-by-value-transformer.scm")

;; dummy declaration to avoid unbound identifier error
(define struct-by-value-transformer #f)

;; these headers are modified for compatibility with chicken bind
(bind-include-path "./include")

(bind-rename/pattern "^cp" "")

(bind-options default-renaming: ""
	      foreign-transformer: struct-by-value-transformer
	      export-constants: true
	      )

;;;; Override definitions

(bind "#define CP_EXPORT")
(bind "#define CP_PI 3.14159265358979")

;; Custom: use ints (or maybe longs?) instead
;; of the default uintptr_t as chicken bind doesn't support this type as
;; a return type
(bind "#define CP_GROUP_TYPE unsigned int")
(bind "#define CP_HASH_VALUE_TYPE unsigned int")
(bind "#define CP_COLLISION_TYPE_TYPE unsigned int")

(define uint
  (foreign-lambda* unsigned-int ((int x))
    "unsigned int n = x;
     C_return(n);") )

;; TODO is it possible to use scheme objects as userdata?
;; (bind "#define CP_DATA_POINTER_TYPE C_word *")

(bind-file "include/chipmunk.h")
