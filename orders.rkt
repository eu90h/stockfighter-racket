#lang racket/base
(provide (all-defined-out))
(define (ok? o)
  (hash-ref o `ok #f))
(define (get-error-string o)
  (hash-ref o `error #f))
(define (order-type o)
  (hash-ref o `orderType #f))
(define (order-id o)
  (hash-ref o `id #f))
(define (order-direction o)
  (hash-ref o `direction #f))
(define (order-fills o)
  (hash-ref o `fills #f))
(define (order-open? o)
  (hash-ref o `open #f))
(define (order-qty o)
  (hash-ref o `qty #f))
(define (order-account o)
  (hash-ref o `account #f))
(define (order-venue o)
  (hash-ref o `venue #f))
(define (order-symbol o)
  (hash-ref o `symbol #f))
(define (order-original-qty o)
  (hash-ref o `originalQty #f))
(define (order-price o)
  (hash-ref o `price #f))
(define (order-time o)
  (hash-ref o `ts #f))
(module+ test
  (require rackunit)
  (define o '#hasheq((price . 3038)
         (symbol . "ADUY")
         (orderType . "limit")
         (ok . #t)
         (ts . "2015-11-29T02:53:36.535655642Z")
         (id . 552)
         (originalQty . 100)
         (direction . "buy")
         (fills
          .
          (#hasheq((price . 3038) (ts . "2015-11-29T02:53:45.95810547Z") (qty . 100))))
         (venue . "IBQEX")
         (totalFilled . 100)
         (account . "IFL33491586")
         (qty . 0)
         (open . #f)))
  (check-true (ok? o))
  (check-equal? (order-id o) 552)
  (check-equal? (order-type o) "limit")
  (check-equal? (order-price o) 3038)
  (check-equal? (order-symbol o) "ADUY")
  (check-equal? (order-original-qty o) 100)
  (check-equal? (order-direction o) "buy")
  (check-equal? (order-venue o) "IBQEX")
  (check-equal? (order-account o) "IFL33491586")
  (check-equal? (order-qty o) 0)
  (check-equal? (order-time o) "2015-11-29T02:53:36.535655642Z")
  (check-false (order-open? o)))