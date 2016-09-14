(module chipmunk
  *
  (import scheme chicken)
  (use srfi-4)

#>
#include <chipmunk/chipmunk_private.h>
#include <chipmunk/chipmunk.h>
#include <chipmunk/cpRobust.h>
<#

;; Bindings for the chipmunk
(include "chipmunk-bind.scm")

(include "chipmunk-callback.scm")

;;;; Vector shorthands

(define (v x y)
  (f64vector x y))

(define v0 (v 0. 0.))

(define (v.x cpv)
  (f64vector-ref cpv 0))

(define (v.y cpv)
  (f64vector-ref cpv 1))

(define v= veql)
(define v+ vadd)
(define v- vsub)
(define v* vmult)
(define v. vdot)

;;;; Vararg variants

(define (space-add-shapes space . shapes)
  (for-each (cut space-add-shape space <>) shapes))

(define (space-add-bodies space . bodies)
  (for-each (cut space-add-body space <>) bodies))

(define (space-add-constraints space . constraint)
  (for-each (cut space-add-constraint space <>) constraint))

;;;; Shapes

(define (shape-get-type shape)
  (let ([type ((foreign-lambda* integer (((c-pointer "cpShape") shape))
                           "C_return(shape->klass->type);")
               shape)])
    (cdr (assq type `((,(foreign-value "CP_CIRCLE_SHAPE" int) . circle)
                      (,(foreign-value "CP_SEGMENT_SHAPE" int) . segment)
                      (,(foreign-value "CP_POLY_SHAPE" int) . poly))))))

;; TODO add getter-with-setter procedures for all get/set pairs
;; <class>-<set|get>-<property>
(define shape-elasticity
  (getter-with-setter
   shape-get-elasticity
   shape-set-elasticity))

;;;; Constraints

(define (constraint-type x)
  (cond
   [(eq? #\x1 (constraint-is-damped-rotary-spring  x)) 'damped-rotary-spring]
   [(eq? #\x1 (constraint-is-damped-spring         x)) 'damped-spring]
   [(eq? #\x1 (constraint-is-gear-joint            x)) 'gear-joint]
   [(eq? #\x1 (constraint-is-groove-joint          x)) 'groove-joint]
   [(eq? #\x1 (constraint-is-pin-joint             x)) 'pin-joint]
   [(eq? #\x1 (constraint-is-pivot-joint           x)) 'pivot-joint]
   [(eq? #\x1 (constraint-is-ratchet-joint         x)) 'ratchet-joint]
   [(eq? #\x1 (constraint-is-rotary-limit-joint    x)) 'rotary-limit-joint]
   [(eq? #\x1 (constraint-is-simple-motor          x)) 'simple-motor]
   [(eq? #\x1 (constraint-is-slide-joint           x)) 'slide-joint]))

;;;; Collision

(define wildcard-collision-type (foreign-value "CP_WILDCARD_COLLISION_TYPE" long))
(define all-categories (foreign-value "(~(cpBitmask)0)" unsigned-int32))
(define wildcard-collision (foreign-value "(~(cpCollisionType)0)" unsigned-int32))

(define no-group (foreign-value "((cpGroup)0)" unsigned-int32))
(define all-groups (foreign-value "(~(cpGroup)0)" unsigned-int32))

;;;; Getter + Setters

(include "chipmunk-getter-with-setters.scm")

)
