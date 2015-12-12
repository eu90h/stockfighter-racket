#lang racket/base
(require net/rfc6455 net/url json racket/class)
(provide json-feed% make-feed-thread stockfighter-executions-url stockfighter-ticker-url)
; a feed object encapsulates a websocket data feed from the stockerfighter exchange
; a feed object is given a callback, which is called whenever data is received
; the callback must be of the form (-> Hash Any)
(define json-feed%
  (class object% (super-new)
    (init-field url callback)
    (field [socket null])
    (connect url)
    (define/private (connect url)
      (unless (or (wss-url? url) (ws-url? url))
        (raise-argument-error `feed%-connect "(or wss-url? ws-url?)" url))
      (set! socket (ws-connect url))
      (listen))
    (define/private (listen)
      (let loop ([in (ws-recv socket #:stream? #t)])
        (define msg (read-json in))
        (if (eof-object? msg)
            (if (ws-conn-closed? socket)
                (connect url)
                (loop (ws-recv socket #:stream? #t)))
            (begin (callback msg)
                   (loop (ws-recv socket #:stream? #t))))))
    (define/public (disconnect)
      (when (ws-conn? socket)
        (ws-close! socket)))))

(define (make-feed-thread url callback)
  (thread (lambda ()
            (new json-feed%
                 [url url]
                 [callback callback]))))

(define (stockfighter-executions-url account venue stock)
  (string->url (string-append
                "wss://api.stockfighter.io/ob/api/ws/"
                account
                "/venues/"
                venue
                "/executions/stocks/"
                stock)))

(define (stockfighter-ticker-url account venue stock)
  (string->url (string-append
                "wss://api.stockfighter.io/ob/api/ws/"
                account
                "/venues/"
                venue
                "/tickertape/stocks/"
                stock)))

(module+ test
(define feed (new json-feed%
                  [url (string->url "ws://localhost:8081/")]
                  [callback (lambda (msg) (displayln (hash-ref msg `qty)))])))