(define (space-add-post-step-callbacks space . post-step-callbacks)
  (for-each
    (lambda (post-step-callback)
      (space-add-post-step-callback space post-step-callback))
    post-step-callbacks)
  space)
(define (space-add-constraints space . constraints)
  (for-each
    (lambda (constraint) (space-add-constraint space constraint))
    constraints)
  space)
(define (space-add-bodys space . bodys)
  (for-each (lambda (body) (space-add-body space body)) bodys)
  space)
(define (space-add-shapes space . shapes)
  (for-each (lambda (shape) (space-add-shape space shape)) shapes)
  space)
(define (space-add-wildcard-handlers space . wildcard-handlers)
  (for-each
    (lambda (wildcard-handler)
      (space-add-wildcard-handler space wildcard-handler))
    wildcard-handlers)
  space)
(define (space-add-collision-handlers space . collision-handlers)
  (for-each
    (lambda (collision-handler)
      (space-add-collision-handler space collision-handler))
    collision-handlers)
  space)
(define (space-add-default-collision-handlers
         space
         .
         default-collision-handlers)
  (for-each
    (lambda (default-collision-handler)
      (space-add-default-collision-handler space default-collision-handler))
    default-collision-handlers)
  space)
(define space-locked? space-is-locked)
(define space-current-time-step space-get-current-time-step)
(define space-static-body space-get-static-body)
(define space-user-data
  (getter-with-setter space-get-user-data space-set-user-data))
(define space-collision-persistence
  (getter-with-setter
    space-get-collision-persistence
    space-set-collision-persistence))
(define space-collision-bias
  (getter-with-setter space-get-collision-bias space-set-collision-bias))
(define space-collision-slop
  (getter-with-setter space-get-collision-slop space-set-collision-slop))
(define space-sleep-time-threshold
  (getter-with-setter
    space-get-sleep-time-threshold
    space-set-sleep-time-threshold))
(define space-idle-speed-threshold
  (getter-with-setter
    space-get-idle-speed-threshold
    space-set-idle-speed-threshold))
(define space-damping (getter-with-setter space-get-damping space-set-damping))
(define space-gravity (getter-with-setter space-get-gravity space-set-gravity))
(define space-iterations
  (getter-with-setter space-get-iterations space-set-iterations))
(define simple-motor-rate
  (getter-with-setter simple-motor-get-rate simple-motor-set-rate))
(define constraint-simple-motor? constraint-is-simple-motor)
(define gear-joint-ratio
  (getter-with-setter gear-joint-get-ratio gear-joint-set-ratio))
(define gear-joint-phase
  (getter-with-setter gear-joint-get-phase gear-joint-set-phase))
(define constraint-gear-joint? constraint-is-gear-joint)
(define ratchet-joint-ratchet
  (getter-with-setter ratchet-joint-get-ratchet ratchet-joint-set-ratchet))
(define ratchet-joint-phase
  (getter-with-setter ratchet-joint-get-phase ratchet-joint-set-phase))
(define ratchet-joint-angle
  (getter-with-setter ratchet-joint-get-angle ratchet-joint-set-angle))
(define constraint-ratchet-joint? constraint-is-ratchet-joint)
(define rotary-limit-joint-max
  (getter-with-setter rotary-limit-joint-get-max rotary-limit-joint-set-max))
(define rotary-limit-joint-min
  (getter-with-setter rotary-limit-joint-get-min rotary-limit-joint-set-min))
(define constraint-rotary-limit-joint? constraint-is-rotary-limit-joint)
(define damped-rotary-spring-spring-torque-func
  (getter-with-setter
    damped-rotary-spring-get-spring-torque-func
    damped-rotary-spring-set-spring-torque-func))
(define damped-rotary-spring-damping
  (getter-with-setter
    damped-rotary-spring-get-damping
    damped-rotary-spring-set-damping))
(define damped-rotary-spring-stiffness
  (getter-with-setter
    damped-rotary-spring-get-stiffness
    damped-rotary-spring-set-stiffness))
(define damped-rotary-spring-rest-angle
  (getter-with-setter
    damped-rotary-spring-get-rest-angle
    damped-rotary-spring-set-rest-angle))
(define constraint-damped-rotary-spring? constraint-is-damped-rotary-spring)
(define damped-spring-spring-force-func
  (getter-with-setter
    damped-spring-get-spring-force-func
    damped-spring-set-spring-force-func))
(define damped-spring-damping
  (getter-with-setter damped-spring-get-damping damped-spring-set-damping))
(define damped-spring-stiffness
  (getter-with-setter damped-spring-get-stiffness damped-spring-set-stiffness))
(define damped-spring-rest-length
  (getter-with-setter
    damped-spring-get-rest-length
    damped-spring-set-rest-length))
(define damped-spring-anchor-b
  (getter-with-setter damped-spring-get-anchor-b damped-spring-set-anchor-b))
(define damped-spring-anchor-a
  (getter-with-setter damped-spring-get-anchor-a damped-spring-set-anchor-a))
(define constraint-damped-spring? constraint-is-damped-spring)
(define groove-joint-anchor-b
  (getter-with-setter groove-joint-get-anchor-b groove-joint-set-anchor-b))
(define groove-joint-groove-b
  (getter-with-setter groove-joint-get-groove-b groove-joint-set-groove-b))
(define groove-joint-groove-a
  (getter-with-setter groove-joint-get-groove-a groove-joint-set-groove-a))
(define constraint-groove-joint? constraint-is-groove-joint)
(define pivot-joint-anchor-b
  (getter-with-setter pivot-joint-get-anchor-b pivot-joint-set-anchor-b))
(define pivot-joint-anchor-a
  (getter-with-setter pivot-joint-get-anchor-a pivot-joint-set-anchor-a))
(define constraint-pivot-joint? constraint-is-pivot-joint)
(define slide-joint-max
  (getter-with-setter slide-joint-get-max slide-joint-set-max))
(define slide-joint-min
  (getter-with-setter slide-joint-get-min slide-joint-set-min))
(define slide-joint-anchor-b
  (getter-with-setter slide-joint-get-anchor-b slide-joint-set-anchor-b))
(define slide-joint-anchor-a
  (getter-with-setter slide-joint-get-anchor-a slide-joint-set-anchor-a))
(define constraint-slide-joint? constraint-is-slide-joint)
(define pin-joint-dist
  (getter-with-setter pin-joint-get-dist pin-joint-set-dist))
(define pin-joint-anchor-b
  (getter-with-setter pin-joint-get-anchor-b pin-joint-set-anchor-b))
(define pin-joint-anchor-a
  (getter-with-setter pin-joint-get-anchor-a pin-joint-set-anchor-a))
(define constraint-pin-joint? constraint-is-pin-joint)
(define constraint-impulse constraint-get-impulse)
(define constraint-user-data
  (getter-with-setter constraint-get-user-data constraint-set-user-data))
(define constraint-post-solve-func
  (getter-with-setter
    constraint-get-post-solve-func
    constraint-set-post-solve-func))
(define constraint-pre-solve-func
  (getter-with-setter
    constraint-get-pre-solve-func
    constraint-set-pre-solve-func))
(define constraint-collide-bodies
  (getter-with-setter
    constraint-get-collide-bodies
    constraint-set-collide-bodies))
(define constraint-max-bias
  (getter-with-setter constraint-get-max-bias constraint-set-max-bias))
(define constraint-error-bias
  (getter-with-setter constraint-get-error-bias constraint-set-error-bias))
(define constraint-max-force
  (getter-with-setter constraint-get-max-force constraint-set-max-force))
(define constraint-body-b constraint-get-body-b)
(define constraint-body-a constraint-get-body-a)
(define constraint-space constraint-get-space)
(define poly-shape-radius poly-shape-get-radius)
(define poly-shape-vert poly-shape-get-vert)
(define poly-shape-count poly-shape-get-count)
(define segment-shape-radius segment-shape-get-radius)
(define segment-shape-normal segment-shape-get-normal)
(define segment-shape-b segment-shape-get-b)
(define segment-shape-a segment-shape-get-a)
(define circle-shape-radius circle-shape-get-radius)
(define circle-shape-offset circle-shape-get-offset)
(define shape-collision-type
  (getter-with-setter shape-get-collision-type shape-set-collision-type))
(define shape-user-data
  (getter-with-setter shape-get-user-data shape-set-user-data))
(define shape-surface-velocity
  (getter-with-setter shape-get-surface-velocity shape-set-surface-velocity))
(define shape-friction
  (getter-with-setter shape-get-friction shape-set-friction))
(define shape-elasticity
  (getter-with-setter shape-get-elasticity shape-set-elasticity))
(define shape-sensor (getter-with-setter shape-get-sensor shape-set-sensor))
(define shape-bb shape-get-bb)
(define shape-center-of-gravity shape-get-center-of-gravity)
(define shape-area shape-get-area)
(define shape-moment shape-get-moment)
(define shape-density (getter-with-setter shape-get-density shape-set-density))
(define shape-mass (getter-with-setter shape-get-mass shape-set-mass))
(define shape-body (getter-with-setter shape-get-body shape-set-body))
(define shape-space shape-get-space)
(define body-velocity-at-local-point body-get-velocity-at-local-point)
(define body-velocity-at-world-point body-get-velocity-at-world-point)
(define body-user-data
  (getter-with-setter body-get-user-data body-set-user-data))
(define body-rotation body-get-rotation)
(define body-torque (getter-with-setter body-get-torque body-set-torque))
(define body-angular-velocity
  (getter-with-setter body-get-angular-velocity body-set-angular-velocity))
(define body-angle (getter-with-setter body-get-angle body-set-angle))
(define body-force (getter-with-setter body-get-force body-set-force))
(define body-velocity (getter-with-setter body-get-velocity body-set-velocity))
(define body-center-of-gravity
  (getter-with-setter body-get-center-of-gravity body-set-center-of-gravity))
(define body-position (getter-with-setter body-get-position body-set-position))
(define body-moment (getter-with-setter body-get-moment body-set-moment))
(define body-mass (getter-with-setter body-get-mass body-set-mass))
(define body-space body-get-space)
(define body-type (getter-with-setter body-get-type body-set-type))
(define body-sleeping? body-is-sleeping)
(define arbiter-depth arbiter-get-depth)
(define arbiter-point-b arbiter-get-point-b)
(define arbiter-point-a arbiter-get-point-a)
(define arbiter-normal arbiter-get-normal)
(define arbiter-count arbiter-get-count)
(define arbiter-removal? arbiter-is-removal)
(define arbiter-first-contact? arbiter-is-first-contact)
(define arbiter-bodies arbiter-get-bodies)
(define arbiter-shapes arbiter-get-shapes)
(define arbiter-user-data
  (getter-with-setter arbiter-get-user-data arbiter-set-user-data))
(define arbiter-surface-velocity
  (getter-with-setter
    arbiter-get-surface-velocity
    arbiter-set-surface-velocity))
(define arbiter-friction
  (getter-with-setter arbiter-get-friction arbiter-set-friction))
(define arbiter-restitution
  (getter-with-setter arbiter-get-restitution arbiter-set-restitution))
