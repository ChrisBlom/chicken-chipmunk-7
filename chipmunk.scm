(module chipmunk
  *
  (import scheme chicken srfi-1 foreign)
  (use srfi-4 srfi-1)

#>
#include <chipmunk/chipmunk_private.h>
#include <chipmunk/chipmunk.h>
#include <chipmunk/cpRobust.h>
<#


(define-foreign-type c-collision-begin-func     (function bool (c-arbiter c-space c-pointer)))
(define-foreign-type c-collision-presolve-func  (function bool (c-arbiter c-space c-pointer)))
(define-foreign-type c-collision-postsolve-func (function void (c-arbiter c-space c-pointer)))
(define-foreign-type c-collision-seperate-func  (function void (c-arbiter c-space c-pointer)))

;; Bindings for the chipmunk
(include "chipmunk-bind.scm")

(include "chipmunk-callback.scm")

;;;; Vector shorthands

(define (v x y)
  (f64vector x y))

(define v0 (v 0. 0.))
(define v1 (v 1. 1.))

(define (v.x cpv)
  (f64vector-ref cpv 0))

(define (v.y cpv)
  (f64vector-ref cpv 1))

(define v= veql)
(define v+ vadd)
(define v- vsub)
(define v* vmult)
(define v. vdot)

(define (vsum vs)
  (reduce v+ v0 vs))

(define (vproduct vs)
  (reduce v* v1 vs))

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

(define shift-left
  (foreign-lambda* unsigned-int32 ((unsigned-int32 i) (unsigned-int32 offset))
    "C_return(i << offset);"))

(define group
  (foreign-lambda* unsigned-int32 ((unsigned-int32 i))
    "C_return(i);"))

(define (bitmask-union elem) (let* ([h (car elem)] [t (cdr elem)] [m (shift-left 1 (- h 1))]) (if (null-list? t) m (bitwise-ior m (bitmask-union t)))))

(define (shape-filter
	 group      ;;
	 categories ;;
	 mask       ;;
	 )
  (shape-filter-new group
		    (bitmask-union categories)
		    (bitmask-union mask)))


(define all-groups (foreign-value "(~(cpGroup)0)" unsigned-int32))

;;;; Getter + Setters

(include "chipmunk-getter-with-setters.scm")

)
