; The purpose of the stockfighter% object is to provide high-level access to
; the stockfighter api.
#lang racket/base
(provide stockfighter%)
(require json openssl net/http-client racket/class racket/port)

; Initializing a stockfighter% object requires a string representing the user's api key:
; (define api-key "541243ab45fcff941ff...")
; (new stockfighter% [key api-key])
;
; all requests return a hash representing the json object received from the stockfighter api
(define stockfighter%
  (class object% (super-new)
    (init-field key)
    (field [ob-endpoint "api.stockfighter.io"]
           [gm-endpoint "www.stockfighter.io"]
           [ob-prefix "/ob/api/"]
           [gm-prefix "/gm/"]
           [port 443]
           [ssl (ssl-make-client-context 'auto)])
    
    (define/public (get-gm-endpoint) gm-endpoint)
    (define/public (get-ob-endpoint) ob-endpoint)
    (define/public (set-gm-endpoint e) (set! gm-endpoint e))
    (define/public (set-ob-endpoint e) (set! ob-endpoint e))

    (define/public (get-gm-prefix) gm-prefix)
    (define/public (get-ob-prefix) ob-prefix)
    (define/public (set-gm-prefix p) (set! gm-prefix p))
    (define/public (set-ob-prefix p) (set! ob-prefix p))
    
    (define/public (get-key) key)
    (define/public (set-key k) (set! key k))
    
    (define/public (get-port) port)
    (define/public (set-port p) (set! port p))
    
    (define/public (ssl-on) (set! ssl (ssl-make-client-context 'auto)))
    (define/public (ssl-off) (set! ssl #f))
    
    (define (http-req method url #:data [data ""] #:gm [gm? #f])
      (define-values (endpoint prefix headers) (if gm?
                                                   (values gm-endpoint gm-prefix (list (string-append "Cookie:api_key=" key)))
                                                   (values ob-endpoint ob-prefix (list (string-append "X-Starfighter-Authorization:" key)))))
      (define-values (status-code response-headers inp)
        (http-sendrecv endpoint (string-append prefix url)
                     #:port port
                     #:ssl? ssl
                     #:method method
                     #:headers headers
                     #:data data))
      (port->jsexpr inp))
    
    (define (get url [gm? #f])
      (http-req 'GET url #:gm gm?))
    
    (define (post url data [gm? #f])
      (http-req 'POST url #:data data #:gm gm?))
    
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
      (post (string-append "venues/" venue "/stocks/" symbol "/orders/" (if (string? order-id) order-id (number->string order-id)) "/cancel") ""))
    
    (define/public (new-instance name)
      (post (string-append "levels/" name) "" #t))

    ;assumes ids are either strings or numbers
    (define/public (restart-instance id)
      (post (string-append "instances/" (if (string? id) id (number->string id)) "/restart") "" #t))

    (define/public (stop-instance id)
      (post (string-append "instances/" (if (string? id) id (number->string id)) "/stop") "" #t))

    (define/public (resume-instance id)
      (post (string-append "instances/" (if (string? id) id (number->string id)) "/resume") "" #t))

    (define/public (instance-info id)
      (post (string-append "instances/" (if (string? id) id (number->string id))) "" #t))))
    
(define port->jsexpr (compose string->jsexpr port->string))