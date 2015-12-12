; The purpose of the stockfighter% object is to provide high-level access to
; the stockfighter api.
#lang racket/base
(provide stockfighter%)
(require json openssl net/http-client racket/class racket/port)

; Initializing a stockfighter% object requires a string representing the user's api key:
; (define api-key "541243ab45fcff941ff...")
; (new stockfighter% [key api-key])
;
; all requests return a hash representing the json object received from the stockfighter api.
(define stockfighter%
  (class object% (super-new)
    (init-field key)
    (field [endpoint "api.stockfighter.io"]
           [prefix "/ob/api/"])
    
    (define/public (set-endpoint new-endpoint) (set! endpoint new-endpoint))
    (define/public (set-prefix new-prefix) (set! prefix new-prefix))
    (define/public (get-endpoint) endpoint)
    (define/public (get-prefix) prefix)
    (define/public (get-key) key)
    
    (define (api-get url)
      (http-sendrecv endpoint (string-append prefix url)
                   #:port 443
                   #:ssl? (ssl-make-client-context 'auto)
                   #:headers (list (string-append "X-Starfighter-Authorization:" key))))
    
    (define (api-post url data)
      (http-sendrecv endpoint (string-append prefix url)
                     #:port 443
                     #:ssl? (ssl-make-client-context 'auto)
                     #:method 'POST
                     #:headers (list (string-append "X-Starfighter-Authorization:" key))
                     #:data data))

    (define (get url)
      (define-values (status-code headers inp) (api-get url))
       (port->jsexpr inp))
    
    (define (post url data)
      (define-values (status-code headers inp) (api-post url data))
      (port->jsexpr inp))
    
    (define/public (is-api-up?)
      (hash-ref (get "heartbeat") 'ok))

    (define/public (is-venue-up? venue)
      (hash-ref (get (string-append "venues/" venue "/heartbeat")) 'ok))

    (define/public (get-stocks venue)
      (get (string-append "venues/" venue "/stocks")))

    (define/public (get-orderbook venue symbol)
      (get (string-append "venues/" venue "/stocks/" symbol)))
    
    (define/public (get-quote venue symbol)
      (get (string-append "venues/" venue "/stocks/" symbol "/quote")))
    ;assumes order-ids are either strings or numbers
    (define/public (get-order-status venue symbol order-id)
      (get (string-append "venues/" venue "/stocks/" symbol "/orders/" (if (string? order-id) order-id (number->string order-id)))))
    
    (define/public (post-order account venue symbol price qty direction type)
      (define order-data (open-output-string))
      (write-json (make-hash (list (cons `account account)
                                   (cons `venue venue)
                                   (cons `symbol symbol)
                                   (cons `price price)
                                   (cons `qty qty)
                                   (cons `direction direction)
                                   (cons `orderType type)))
                  order-data)
      (post (string-append "venues/" venue "/stocks/" symbol "/orders")
            (get-output-string order-data)))
    ;assumes order-ids are either strings or numbers
    (define/public (cancel-order venue symbol order-id)
      (post (string-append "venues/" venue "/stocks/" symbol "/orders/" (if (string? order-id) order-id (number->string order-id)) "/cancel") ""))))

(define port->jsexpr (compose string->jsexpr port->string))