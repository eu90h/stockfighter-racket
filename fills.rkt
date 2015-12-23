#lang racket/base
(provide (all-defined-out))
(require "time.rkt")

(define (fill-qty f)
  (hash-ref f `qty #f))

(define (fill-price f)
  (hash-ref f `price #f))

(define (fill-time f)
  (hash-ref f `ts #f))

(define (newest-fill fills)
  (unless (list? fills)
    (raise-argument-error `fill-newest "list?" fills))
  (when (null? fills)
    (raise-argument-error `fill-newest "not-null?" fills))
  (let find-newest ([fills fills] [best (car fills)])
    (if (null? fills)
        best
        (find-newest (cdr fills)
                     (if (date-string>=? (fill-time (car fills))
                                         (fill-time best))
                         (car fills)
                         best)))))
(module+ test
  (require rackunit)
  (define fill0 #hasheq((price . 3038)
                        (ts . "2015-11-29T02:53:45.95810547Z")
                        (qty . 100)))
  (define fill1 #hasheq((price . 3030)
                        (ts . "2015-11-29T02:53:46.00000001Z")
                        (qty . 80)))
  (check-equal? (fill-qty fill0) 100)
  (check-equal? (newest-fill (list fill0 fill1)) fill1))
  