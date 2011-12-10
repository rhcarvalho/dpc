#lang class/0

;; RUBRIC
;; ========================================================

;; Problem set 3, Problem 1 (total 20 points)

;; Check that this is their code, and not the same as the solution to Problem set 2
;; Otherwise, 0 points for Problem 1

;; 10 points for completeness:
;; - run the game, make sure it runs and it all works
;; 10 points for functional abstraction:
;; - if there's no duplicated code, they get the full 10 points
;; - otherwise, deduct points at your discretion

;; =======================================================

;; ==========================================================
;; Play the classic game of Zombie Attack!

;; All zombies move toward the player.  The player moves 
;; toward the mouse. Zombies collision cause flesh heaps 
;; that are deadly to other zombies and the player.  
;; Randomly teleport via mouse click as a last resort!

;; Based on Robot!, p. 234 of Barski's Land of Lisp.


(require 2htdp/image)
(require class/universe)

(define CELL 20)
(define 1/2-CELL (/ CELL 2))
(define WIDTH 400)
(define HEIGHT 400)
(define MT-SCENE (empty-scene WIDTH HEIGHT))
(define P-SPEED 5)
(define Z-SPEED 1)

;; ==========================================================
;; A World is a (new world% Player LoZ Mouse).
;; Interp: player, list of living and dead zombies, mouse.

;; name : -> String
;; The name of the game.

;; tick-rate : -> Number
;; The animation rate for the game.

;; on-tick : -> World
;; Kill any zombies and move player and zombies.

;; to-draw : -> Scene
;; Draw the player and live and dead zombies.

;; on-mouse : Int Int MouseEvent -> World
;; Handle mouse events. 

;; teleport : -> World
;; Teleport to random location.

;; mouse-move : Int Int -> World
;; Record mouse movement.

;; kill : -> World
;; Kill all zombies that touch other zombies.

(define-class world%
  (fields player zombies mouse)
  
  (define/public (name) "Zombie Attack!")
    
  (define/public (tick-rate) 1/10)
  
  (define/public (on-tick)
    (send (kill) move))  
  
  (define/public (to-draw)
    (send (field zombies) draw-on
          (send (field player) draw-on
                MT-SCENE)))
  
  (define/public (on-mouse x y m)
    (cond [(mouse=? "button-down" m)
           (teleport)]
          [(mouse=? "move" m)
           (mouse-move x y)]
          [else this]))    

  (define/public (teleport)
    (new world%
         (new player% 
              (random WIDTH)
              (random HEIGHT))
         (field zombies)
         (field mouse)))
  
  (define/public (mouse-move x y)
    (new world%
         (field player)
         (field zombies)
         (new mouse% x y)))
  
  (define/public (stop-when)
    (send (field zombies) touching? (field player)))  

  (define/public (move)
    (new world%
         (send (field player) move-toward (field mouse))
         (send (field zombies) move-toward (field player))
         (field mouse)))
  
  (define/public (kill)      
    (new world%
         (field player)
         (send (field zombies) kill)
         (field mouse))))


;; ==========================================================
;; A Player is a (new player% [0,WIDTH] [0,HEIGHT]).

;; draw-on : Scene -> Scene
;; Draw this player on the scene.

;; plus : Vec -> Player
;; Move this player by the given vector.

;; move-toward : Mouse -> Player
;; Move this player toward the given mouse position.

(define-class player%
  (fields x y)
  
  (define/public (draw-on scn)
    (place-image (circle 1/2-CELL "solid" "green")
                 (field x)
                 (field y)
                 scn))
  
  (define/public (move-toward mouse)
    (plus (min-taxi this P-SPEED mouse)))
  
  (define/public (plus v)
    (new player%
         (+ (field x) (send v x))
         (+ (field y) (send v y)))))


;; ==========================================================
;; Vec is a (new vec% Int Int).
(define-class vec% (fields x y))


;; ==========================================================
;; A Mouse is a (new mouse% Int Int).
(define-class mouse% (fields x y))


;; ==========================================================
;; A Zombie is one of:
;; - LiveZombie 
;; - DeadZombie

;; move-toward : Player -> Zombie
;; Move this zombie toward the given player.

;; touching? : [U Player Zombie] -> Boolean
;; Is this zombie touching the given player or zombie?

;; draw-on : Scene -> Scene
;; Draw this zombie on the given scene.

;; kill : -> DeadZombie
;; Make this zombie dead.

;; A DeadZombie is a (new dead-zombie% [0,WIDTH] [0,HEIGHT]).
;; A LiveZombie is a (new live-zombie% [0,WIDTH] [0,HEIGHT]).

;; plus : Vec -> LiveZombie
;; Move this zombie by the given vector.
(define-class live-zombie% 
  (fields x y)
  
  (define/public (move-toward p)
    (plus (min-taxi this Z-SPEED p)))
  
  (define/public (touching? p)
    (zombie-touching? this p))
  
  (define/public (draw-on scn)
    (place-image (circle 1/2-CELL "solid" "red")
                 (field x)
                 (field y)
                 scn))
  
  (define/public (kill)
    (new dead-zombie% (field x) (field y)))
  
  (define/public (plus v)
    (new live-zombie% 
         (+ (field x) (send v x))
         (+ (field y) (send v y)))))
    
(define-class dead-zombie% 
  (fields x y)
  (define/public (move-toward p)
    this)
  
  (define/public (touching? p)
    (zombie-touching? this p))
  
  (define/public (draw-on scn)
    (place-image (circle 1/2-CELL "solid" "gray")
                 (field x)
                 (field y)
                 scn))
  
  (define/public (kill)
    (new dead-zombie% (field x) (field y))))


;; ==========================================================
;; A LoZ is one:
;; - (new empty%)
;; - (new cons% Zombie LoZ)

;; draw-on : Scene -> Scene
;; Draw this list of zombies on the scene.

;; touching? : [U Player Zombie] -> Boolean
;; Are any of these zombies touching the player or zombie?

;; move-toward : Player -> LoDot
;; Move all zombies toward the player.

;; kill : -> LoZ
;; Kill any zombies that touch others.

(define-class empty%
  (define/public (draw-on scn)
    scn)
  
  (define/public (touching? pz)
    false)
  
  (define/public (move-toward p)
    this)
  
  (define/public (kill)    
    this)
  
  (define/public (kill/acc seen)
    this))

(define-class cons%
  (fields first rest)
  
  (define/public (draw-on scn)
    (send (field first) draw-on
          (send (field rest) draw-on scn)))
  
  (define/public (touching? pz)
    (or (send (field first) touching? pz)
        (send (field rest) touching? pz)))
  
  (define/public (move-toward p)
     (new cons% 
         (send (field first) move-toward p)
         (send (field rest) move-toward p)))
  
  (define/public (kill) 
    (kill/acc (new empty%)))
  
  (define/public (kill/acc seen)
    ;; does first touch anything in rest or seen?
    (cond [(or (send seen touching? (field first))
               (send (field rest) touching? (field first)))
           (new cons%
                (send (field first) kill)
                (send (field rest) kill/acc
                      (new cons% (field first) seen)))]          
          [else
           (new cons%
                (field first)
                (send (field rest) kill/acc
                      (new cons% (field first) seen)))])))

;; ==========================================================
;; Functional abstractions

;; [U Player Zombie] [U Player Mouse] -> Nat
;; Compute the taxi distance between the given positions.
(define (dist p1 p2)
  (+ (abs (- (send p1 x)
             (send p2 x)))
     (abs (- (send p1 y)
             (send p2 y)))))

;; Zombie [U Player Zombie] -> Boolean
(define (zombie-touching? z p)
  (<= (dist z p) 1/2-CELL))

;; [U Player LiveZombie] Nat [U Player Mouse] -> Vec
(define (min-taxi from n to)
  ;; Vec Vec -> Vec
  (local [(define (select-shorter-dir d1 d2)
            (cond [(< (dist (send from plus d1) to)
                      (dist (send from plus d2) to))
                   d1]
                  [else d2]))]
    (foldl (λ (d sd) 
             (select-shorter-dir sd
                                 (new vec% 
                                      (* n (send d x)) 
                                      (* n (send d y)))))
           (new vec% 0 0)
           DIRS)))

(define DIRS
  (list (new vec% -1 -1)
        (new vec% -1  0)
        (new vec% -1 +1)
        (new vec%  0 -1)
        (new vec%  0  0)
        (new vec%  0 +1)
        (new vec% +1 -1)
        (new vec% +1  0)
        (new vec% +1 +1)))


;; ==========================================================
;; Helper constructor for LoZ

;; Nat (-> Nat Zombie) -> LoZ
;; Like build-list for LoZ.
(check-expect (build-loz 0 (λ (i) (new live-zombie% i i)))
              (new empty%))
(check-expect (build-loz 2 (λ (i) (new live-zombie% i i)))
              (new cons% 
                   (new live-zombie% 0 0)
                   (new cons%
                        (new live-zombie% 1 1)
                        (new empty%))))
(define (build-loz n f)
  (local [(define (loop i)
            (cond [(= i n) (new empty%)]
                  [else
                   (new cons% 
                        (f i)
                        (loop (add1 i)))]))]
    (loop 0)))


;; ==========================================================
;; Run program, run!
(big-bang
 (new world%
      (new player% (/ WIDTH 2) (/ HEIGHT 2))
      (build-loz (+ 10 (random 20))
                 (λ (_)
                   (new live-zombie% 
                        (random WIDTH)
                        (random HEIGHT))))
      (new mouse% 0 0)))


;; ==========================================================
;; Test cases

(define mt (new empty%))
(define m0 (new mouse% 0 0))
(define m1 (new mouse% 0 30))
(define p0 (new player% 0 0))
(define p1 (new player% 0 30))
(define l0 (new live-zombie% 0 0))
(define d0 (new dead-zombie% 0 0))
(define l1 (new live-zombie% 0 30))
(define d1 (new dead-zombie% 0 30))
(define lz0 (new cons% l0 mt))
(define dz0 (new cons% d0 mt))
(define dz1 (new cons% d1 mt))
(define zs0 (new cons% l1 dz1))
(define w0 (new world% p0 mt m0))
(define w1 (new world% d0 lz0 m0))
(define w2 (new world% d0 dz0 m0))
(define w3 (new world% p0 mt m1))
(define w4 (new world% p0 zs0 m1))
(define w5
  (new world% 
       (new player% 0 P-SPEED)
       (new cons% (new live-zombie% 0 (- 30 Z-SPEED)) dz1)
       m1))
(define w6 (new world% p0 (new cons% d1 dz1) m1))
(define w7 (send w0 teleport))

;; World tests
;; ===========

;; on-mouse
(check-expect (send w0 on-mouse 0 30 "drag") w0)
(check-expect (send w0 on-mouse 0 30 "move") w3)
;; teleport
(check-range (send (send w7 player) x) 0 WIDTH)
(check-range (send (send w7 player) y) 0 HEIGHT)
(check-expect (send w7 zombies) mt)
(check-expect (send w7 mouse) m0)
;; mouse-move
(check-expect (send w0 mouse-move 0 30)
              (new world% p0 mt m1))
;; stop-when
(check-expect (send w0 stop-when) false)
(check-expect (send w1 stop-when) true)
(check-expect (send w2 stop-when) true)
;; move
(check-expect (send w4 move) w5)
;; kill
(check-expect (send w4 kill) w6)

;; Player tests
;; ============

;; draw-on
(check-expect (send p0 draw-on MT-SCENE)
              (place-image (circle 1/2-CELL "solid" "green")
                           0 0
                           MT-SCENE))
;; plus
(check-expect (send p0 plus (new vec% 0 0)) p0)
(check-expect (send p0 plus (new vec% 0 30)) p1)
;; move-toward
(check-expect (send p0 move-toward m0) p0)
(check-expect (send p0 move-toward m1)
              (new player% 0 P-SPEED))

;; Zombie tests
;; ============

;; kill
(check-expect (send l0 kill) d0)
(check-expect (send d0 kill) d0)
;; touching?
(check-expect (send l0 touching? p0) true)
(check-expect (send l0 touching? p1) false)
;; move-toward
(check-expect (send l0 move-toward p0) l0)
(check-expect (send l0 move-toward p1)
              (new live-zombie% 0 Z-SPEED))
;; draw-on
(check-expect (send l0 draw-on MT-SCENE)
              (place-image (circle 1/2-CELL "solid" "red")
                           0 0
                           MT-SCENE))
(check-expect (send d0 draw-on MT-SCENE)
              (place-image (circle 1/2-CELL "solid" "gray")
                           0 0
                           MT-SCENE))

;; LoZ tests
;; =========

;; draw-on
(check-expect (send mt draw-on MT-SCENE) MT-SCENE)
(check-expect (send dz1 draw-on MT-SCENE)
              (send d1 draw-on MT-SCENE))
;; touching?
(check-expect (send mt touching? p0) false)
(check-expect (send dz0 touching? p0) true)
(check-expect (send dz0 touching? p1) false)
;; move-toward
(check-expect (send mt move-toward p0) mt)
(check-expect (send dz0 move-toward p0) dz0)
(check-expect (send lz0 move-toward p1)
              (new cons% (new live-zombie% 0 Z-SPEED)
                   mt))
;; kill
(check-expect (send mt kill) mt)
(check-expect (send lz0 kill) lz0)
(check-expect (send zs0 kill) (new cons% d1 dz1))

;; Function tests
;; ==============

;; dist
(check-expect (dist l0 p1) 30)
;; min-taxi
(check-expect (min-taxi l0 5 p0) (new vec% 0 0))
(check-expect (min-taxi l0 5 p1) (new vec% 0 5))
;; zombie-touching?
(check-expect (zombie-touching? l0 p0) true)
(check-expect (zombie-touching? l0 l0) true)
(check-expect (zombie-touching? l0 p1) false)
