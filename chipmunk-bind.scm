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

(bind-file "include/chipmunk_types.h")

(bind-file "include/cpVect.h")
(bind-file "include/cpBB.h")

(bind-file "include/cpSpatialIndex.h")
(bind-file "include/cpTransform.h")
(bind-file "include/cpArbiter.h")
(bind-file "include/cpConstraint.h")
(bind-file "include/cpShape.h")
(bind-file "include/cpSpace.h")
(bind-file "include/cpRobust.h")

;;(bind-file "include/chipmunk.h")
