#lang racket/base
(provide open-feed read-feed feed-ready? feed-closed?
         stockfighter-executions-url stockfighter-ticker-url)

(require net/rfc6455 net/url json racket/class)

(define (open-feed url)
  (unless (or (wss-url? url) (ws-url? url))
    (raise-argument-error `open-feed "(or wss-url? ws-url?)" url))
  (ws-connect url))

(define (read-feed feed)
  (define in (ws-recv feed #:stream? #t))
  (unless (eof-object? in)
    (read-json in)))

(define (feed-ready? feed)
  (port? (sync/timeout 0 feed)))

(define (feed-closed? feed)
  (ws-conn-closed? feed))

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