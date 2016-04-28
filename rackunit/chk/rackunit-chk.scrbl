#lang scribble/doc
@(require scribble/manual
          (for-label racket/base
                     rackunit/chk
                     syntax/parse))

@title[#:tag "rackunit-chk"]{rackunit-chk: a short hand for writing rackunit tests}
@author+email["Jay McCarthy" "jay@racket-lang.org"]

@defmodule[rackunit/chk]

This module defines a macro, @racket[chk], that allows you to write
many @racketmodname[rackunit] tests quickly. In addition, it provides
some convenient wrappers around @racketmodname[rackunit]'s checks that
work better with multiple values and exceptions.

@defform[(chk test ...)]{

Runs each @racket[test] provided it matches the following grammar:

@racketgrammar*[#:literals (~seq)
                [test
                 strict-test
                 (~seq actual expected)
                 (~seq actual)]
                [strict-test
                 (~seq #:f test)
                 (~seq #:t actual)
                 (~seq #:exn actual exn-expected)
                 (~seq #:= actual expected)]]

If a @racket[_test] is not @racket[_strict-test], then if it has two
expressions, it is equivalent to a @racket[#:=]
@racket[_strict-test]. If it has one, it is equivalent to a
@racket[#:t] @racket[_strict-test].

A @racket[#:f] @racket[_strict-test] is equivalent to the opposite of the test
provided as an argument.

A @racket[#:t] @racket[_strict-test] is equivalent to
@racket[check-not-false]. Its opposite is @racket[check-false].

A @racket[#:exn] @racket[_strict-test] is equivalent to
@racket[check-exn]. Its opposite is @racket[check-not-exn].

A @racket[#:=] @racket[_strict-test] is equivalent to
@racket[check-equal?]. Its opposite is @racket[check-not-equal?].

}

@defform[(check-equal? x y)]{Checks if either (a) @racket[x] and
@racket[y] evaluate to the same values (compared with @racket[equal?])
or that (b) they both evaluate to exceptions with the same message.}

@defform[(check-not-equal? x y)]{Negation of @racket[(check-equal? x y)].}

@defform[(check-not-false x)]{Checks that @racket[x] does not evaluate to @racket[#f].}
@defform[(check-false x)]{Checks that @racket[x] does evaluate to @racket[#f].}

@defform[(check-exn x e)]{Checks that @racket[x] throws an exception
during execution. If @racket[e] evaluates to a string, then it must
occur inside the exception message. If @racket[e] evaluates to a
regexp, then it must match against the exception message. If
@racket[e] evaluates to a procedure, it must not return @racket[#f] on
the exception.}

@defform[(check-not-exn x e)]{Checks that if @racket[x] throws an
exception during execution, the exception does not match @racket[e]
according to the rules of @racket[check-exn].}

Consider the following examples:

@(require scribble/example)

@examples[(require rackunit/chk)
          (chk
           1 1
           #:f 1 0
           #:f #:f #:f 1 0
           #:f #:f 1 1
           #:f (/ 1 0) +inf.0
           (/ 1 0) (/ 1 0)
           #:f (error 'xxx "a") (error 'xxx "b")

           #:f #:t (/ 1 0)
           #:t (values 0 1)
           #:t (values #f 1)
           #:f #:t (values #f 1)

           1 1
           2 2
           #:exn (/ 1 0) "division"
           #:exn (/ 1 0) #rx"di.ision"
           #:exn (/ 1 0) exn:fail?
           #:f #:exn (/ 1 1) "division"
           #:f #:exn (/ 1 0) "diblision"
           (/ 1 0) (error '/ "division by zero")

           #:t (chk 1)
           #:t 1
           #:f #f
           #:f #:t #f
           1 1
           #:t 1
           #:f 2 3

           (values 1 2) (values 1 2)
           #:f (values 1 2) (values 2 3)
           #:f (values 1 2) 3
           #:f 3 (values 1 2)
           (quotient/remainder 10 3) (values 3 1)

           #:= 1 1
           [#:exn (/ 1 0) "division"]
           [#:f #f]
           [#:t 1]
           [#:= 1 1])]
