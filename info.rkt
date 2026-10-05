#lang info
(define collection "stockfighter-api")
(define deps '("srfi-lite-lib"
               "base"
               "rackunit-lib"
               "rfc6455"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/stockfighter-api.scrbl" ())))
(define pkg-desc "Stockfighter Client")
(define version "0.0")
(define pkg-authors '(eu90h))
