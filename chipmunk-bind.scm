(import chicken bind foreign srfi-4)

(include "struct-by-value-transformer.scm")

;; dummy declaration to avoid unbound identifier error
(define struct-by-value-transformer #f)

;; these headers are modified for compatibility with chicken bind
(bind-include-path "./include")

(bind-rename/pattern "^cp" "")

(bind-options default-renaming: ""
	      foreign-transformer: struct-by-value-transformer)

(bind "#define CP_EXPORT")
(bind "#define CP_PI 3.14159265358979")

;; by default its uintprt_t but chicken scheme does not like that
(bind "#define CP_COLLISION_TYPE_TYPE long")


(bind-file "include/chipmunk.h")
