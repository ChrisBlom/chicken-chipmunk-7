(module chipmunk
  *
  (import scheme chicken)

#>
#include <chipmunk/chipmunk_private.h>
#include <chipmunk/chipmunk.h>
#include <chipmunk/cpRobust.h>
<#

(include "chipmunk-bind.scm")

(include "chipmunk-callback.scm")

(define (v x y)
  (f64vector x y))

(define vzero (v 0. 0.))

)
