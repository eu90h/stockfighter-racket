stockfighter-api
================
A Racket client for [Stockfighter](https://stockfighters.io).
The documentation is non-existent, however between the examples and the official docs its usage should be clear.

Overview
========
The `stockfighter.rkt` file contains the main client object. It posts orders, retrieves their status, etc. API responses are represented as hashes corresponding to the received JSON object.

Additionally, the files `fills`, `orders`, and `quotes` contain various useful functions for manipulating common data types in Stockfighter.

Finally, `feed.rkt` contains procedures for handling stockfighter websocket data feeds.

For more info see the source!

Usage
======
To install
`raco pkg install https://github.com/eu90h/stockfighter-racket`

To remove
`raco pkg remove stockfighter-api`

To use
`(require stockfighter-api)`
