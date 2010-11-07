#lang scribble/manual
@(require scribble/eval)

@(require (for-label lang/htdp-intermediate-lambda))

@(define the-eval
  (let ([the-eval (make-base-eval)])
    (the-eval `(require (only-in lang/htdp-intermediate-lambda sqr)))
    (the-eval `(require test-engine/racket-tests))
    ;(the-eval `(require lang/htdp-intermediate-lambda))
    the-eval))

@title{@bold{Fundamentals of Computer Science II (Honors)}
       @linebreak[]
       Introduction to Class-based Program Design}

@larger{@bold{Spring, 2011}}

The course studies the class-based program design and the design
of abstractions that support the design of reusable software and
libraries. It covers the principles of object oriented program 
design, the basic rules of program evaluation, and examines the 
relationship between algorithms and data structures, as well as 
basic techniques for analyzing algorithm complexity.

The course is suitable for both CS majors and non-majors.  It 
assumes that student has been introduced to the basic principles 
of program design and computation. 

@bold{Prerequisites}

The course assumes proficiency with the systematic design of 
programs and some mathematical maturity. It demands curiosity 
and self-driven exploration and requires a serious commitment 
to practical hands-on programming. 

@include-section["general.scrbl"]

@include-section["texts.scrbl"]

@include-section["syllabus.scrbl"]

@include-section["lectures.scrbl"]

@include-section["labs.scrbl"]

@section{Assignments}

Assignment are due on a weekly basis, Wednesday at midnight.


@subsection[#:tag "pair"]{Pair Programming}

Pair programming emerged in the 1990s in several different settings. 
Companies realized that when individual programmers left, they were 
left with a team that lacked knowledge of critical pieces of software.
Academics began to understand the importance of articulating technical 
ideas and discussing programs for the design process

Roughly speaking, pair programming is a collaboration technique. As 
the name says, you and a partner design programs together. In practice, 
one of you---called the pilot---is at the keyboard and the other one---the
co-pilot---is looking over the pilot's shoulder, reading and analyzing and
questioning what the pilot types. To make this work, the pilot must explain
what he is doing, somewhat in a stream of consciousness fashion. When a 
defined sub-problem is solved, the partners switch roles to counter-act 
fatigue and to distribute knowledge uniformly.

Experience suggests that pair programming is more effective than individual
programming, even though it imposes its own costs on the process. To 
understand this point, Williams and Kessler conducted an extensive study 
of pair programming practices in the late 1990s. Academia benefits from pair
programming because programmers train each other making it less likely that 
an individual hangs on to a misunderstanding for a long time. Industry 
benefits from the practice for the same reasons but also because many 
programmers understand a lot of the overall system. If a programmer moves 
on, those who stay can easily reconstruct the workings of any component.

Read more about pair programming in William and Kessler's well-known CACM 
article on pair programming and William's dissertation on the same topic, 
which has appeared as a jointly authored book (Pair Programming Illuminated) 
with Addison and Wesley. 

@subsection[#:tag "style"]{The Style}

In addition to following the design recipe, all code written for this class
should adhere to the following basic style guidelines for your programs:

@itemlist[#:style 'ordered]{
  @item{No line should...}}

@subsection[#:tag "assign01"]{1/12: Complex}

Due: 1/12.

Language: ISL+λ + class0.

@itemlist[#:style 'ordered 
 @item{@bold{The @racket[complex%] class.}
       
        For this exercise, you will develop a class-based representation
        of complex numbers, which are used in several fields, including:
        engineering, electromagnetism, quantum physics, applied mathematics, 
        and chaos theory.        
        
        A @emph{complex number} is a number consisting of a real and 
        imaginary part. It can be written in the mathematical notation @emph{a+bi},
        where @emph{a} and @emph{b} are real numbers, and @emph{i} is the standard
        imaginary unit with the property @emph{i@superscript{2} = −1}.
        
        @margin-note{You can read more about the sophisticated number system of Racket
        in the 
        @other-manual['(lib "scribblings/guide/guide.scrbl")]
        section on
        @secref["numbers" #:doc
                          '(lib "scribblings/guide/guide.scrbl")].}
        Complex numbers are so useful, it turns out they are included
        in the set of numeric values that Racket supports.          
        The Racket notation for writing down complex numbers is @racket[5+3i], 
        where this number has a real part of @racketresult[5] and an 
        imaginery part of @racketresult[3]; @racket[4-2i] has a real 
        part of @racketresult[4] and imaginary part of @racketresult[-2].
        (Notice that complex numbers
        @emph{generalize} the real numbers since any real number can be
        expressed as a complex number with an imaginery part of 
        @racketresult[0].)        
        Arithmetic operations on
        complex numbers work as they should, so for example, you can
        add, subtract, multiply, and divide complex numbers.  (One thing
        you can't do is @emph{order} the complex numbers, so @racket[<]
        and friends work only on real numbers.)
        
        @examples[#:eval the-eval
                         @code:comment{Verify the imaginary unit property.}
                         (sqr (sqrt -1))
                         (sqr 0+1i)
                         @code:comment{Arithmetic on complex numbers.}
                         (+ 2+3i 4+5i)
                         (- 2+3i 4+5i)
                         (* 2+3i 4+5i)
                         (/ 2+3i 4+5i)
                         @code:comment{Complex numbers can't be ordered.}
                         (< 1+2i 2+3i)
                         @code:comment{Real numbers are complex numbers with an imaginary part of 0,}
                         @code:comment{so you can perform arithmetic with them as well.}
                         (+ 2+3i 2)
                         (- 2+3i 2)
                         (* 2+3i 2)
                         (/ 2+3i 2)]
 
        @(begin0 
           "" 
           (the-eval '(require racket/class))
           (the-eval 
            `(begin 
               (struct complex (real imag) #:transparent)
               (define ((liftb f) x y) 
                 (f (to-number x) (to-number y)))
               (define ((lift2 f) x y)
                 (from-number (f (to-number x) (to-number y))))
               (define ((lift1 f) x)
                 (from-number (f (to-number x))))
               (define (from-number n)
                 (make-complex (real-part n) (imag-part n)))
               (define (to-number c)
                 (+ (complex-real c) (* +1i (complex-imag c))))
               (define =? (liftb =))
               (define plus (lift2 +))
               (define minus (lift2 -))
               (define times (lift2 *))
               (define div (lift2 /))
               (define sq (lift1 sqr))
               (define sqroot (lift1 sqrt))))
           (the-eval
            `(define complex%
               (class* object% ()
                 (inspect #f)
                 (super-new)
                 (init [(the-real real)]
                       [(the-imag imag)])
                 
                 (define n (+ the-real (* +i the-imag)))
                 
                 (define/public (real) (real-part n))
                 (define/public (imag) (imag-part n))
                 
                 (define/public (=? c)
                   (= n (send c to-number)))
                 
                 (define/public (plus c)
                   (from-number (+ n (send c to-number))))
                 
                 (define/public (minus c)
                   (from-number (- n (send c to-number))))
                 
                 (define/public (times c)
                   (from-number (* n (send c to-number))))
                 
                 (define/public (div c)
                   (from-number (/ n (send c to-number))))
                 
                 (define/public (sq)
                   (from-number (sqr n)))
                 
                 (define/public (sqroot)
                   (from-number (sqrt n)))
                 
                 (define/private (from-number c)
                   (new complex% 
                        [real (real-part c)]
                        [imag (imag-part c)]))
                 
                 (define/public (to-number) n)))))
        
        Supposing your language was impoverished and didn't support
        complex numbers, you should be able to build them yourself 
        since complex numbers are easily represented as a pair of real 
        numbers---the real and imaginary parts.
        
        Design a structure-based data representation for @tt{Complex}
        values.
        Design the functions @racket[=?], @racket[plus], @racket[minus],
        @racket[times], @racket[div], @racket[sq], and @racket[sqroot].
        Finally, design a utility function
        @racket[to-number] which can convert @tt{Complex} values into
        the appropriate Racket complex number.  Only the code and tests
        for @racket[to-number] should use Racket's complex (non-real)
        numbers and arithmetic since the point is to build these things
        for yourself.  However, you can use Racket to double-check your 
        understanding of complex arithmetic.
        
        @examples[#:eval the-eval
                         (define c-1  (make-complex -1 0))
                         (define c0+0 (make-complex 0 0))                         
                         (define c2+3 (make-complex 2 3))
                         (define c3+5 (make-complex 4 5))
                         (=? c0+0 c0+0)
                         (=? c0+0 c2+3)
                         (=? (plus c2+3 c3+5)
                             (make-complex 6 8))]
        
        Develop a class-based data representation for @tt{Complex}
        values.
        Add accessor methods for extracting the @racket[real] and @racket[imag] 
        parts.
        Develop the methods @racket[=?], @racket[plus], @racket[minus],
        @racket[times], @racket[div], @racket[sq], @racket[sqroot] and
        @racket[to-number].
        
        @examples[#:eval the-eval
                         @code:comment{Some example Complex values.}
                         (define c-1  (new complex% [real -1] [imag 0]))
                         (define c0+0 (new complex% [real 0] [imag 0]))
                         (define c2+3 (new complex% [real 2] [imag 3]))
                         (define c3+5 (new complex% [real 4] [imag 5]))
                         @code:comment{Verify the imaginary unit property.}
                         (send (send (send c-1 sqroot) sq) =? c-1)
                         (send (send (new complex% [real 0] [imag 1]) sq) =? c-1)
                         @code:comment{Arithmetic on complex numbers.}
                         (send c0+0 =? c0+0)
                         (send c0+0 =? c2+3)
                         (send (send c2+3 plus c3+5) =?
                               (new complex% [real 6] [imag 8]))
                         (send (send c2+3 minus c3+5) =?
                               (new complex% [real -2] [imag -2]))
                         (send (send c2+3 times c3+5) =?
                               (new complex% [real -7] [imag 22]))
                         (send (send c2+3 div c3+5) =?
                               (new complex% [real 23/41] [imag 2/41]))]
                         
        }
 
 @item{@bold{SVN basics}
        
        Check in your assigment.}]

@subsection[#:tag "assign02"]{1/19 - Quick Edit & Snake}

@itemlist[#:style 'ordered 
 @item{@bold{QuickEdit.}
        
        Develop...}
 @item{@bold{Snake.}
        
        Develop...}]



@subsection[#:tag "assign03"]{1/26 - Quick Chat}

@itemlist[#:style 'ordered
  @item{@bold{QuickChat}
         
         Starting with your QuickEdit program from last week's assignment,
         develop QuickChat, a Universe-based chat client.}]

@subsection[#:tag "assign04"]{2/2}
@subsection[#:tag "assign05"]{2/2}
@subsection[#:tag "assign06"]{2/9}
@subsection[#:tag "assign07"]{2/16}
@subsection[#:tag "assign08"]{2/23}
@subsection[#:tag "assign09"]{3/2 - Spring break}
@subsection[#:tag "assign10"]{3/9}
@subsection[#:tag "assign11"]{3/16}
@subsection[#:tag "assign12"]{3/23}
@subsection[#:tag "assign13"]{3/30}
@subsection[#:tag "assign14"]{4/6}
@subsection[#:tag "assign15"]{4/13}
@subsection[#:tag "assign16"]{4/20}

@section{Blog}

@subsection{Welcome to CS2510H.}
              