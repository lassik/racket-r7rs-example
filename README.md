# Racket R7RS Example

This is a minimal example of importing portable Scheme code into
Racket.

## The Racket R7RS Shim

Racket doesn't ship with R7RS support. It's in the third-party package
`r7rs` by Alexis King: https://github.com/lexi-lambda/racket-r7rs
Despite not being an official part of Racket, it worked just fine for
me (I used a moderately complex library to do HTML parsing and wrote
some farily involved string processing and tree walking on top of it,
so this is definitely useful for real work).

You can install the shim via `raco pkg install r7rs`. Note also that
`info.rkt` lists `r7rs` in the dependencies, which you need for Heroku
and the like.

## Modules

* `app` -- a Racket application
* `lib` -- an R7RS library used by `app`
* `sublib` -- an R7RS library used by `lib`

## What files the modules are made of

So `app` needs just one file, `app.rkt`, like any normal Racket
module.

But `lib` and `sublib` need 3 files each. `lib.scm` is the Scheme
code. `lib.sld` is the Scheme library definition. And `lib.rkt` is a
Racket wrapper for it. Technically you could combine `lib.sld` and
`lib.scm` into one file but it's cleaner to have them separate. You
could also copy all your Scheme code directly into `lib.rkt` but then
you can't import it into other Schemes.

Note that `lib.scm` doesn't have an `(import ...)` form at the top.
The imports are inside the `define-library` form in `lib.sld`. The
`define-library` form uses `(include ...)` to include the actual code
in `lib.scm`.

The job of `lib.rkt` is just to say `#lang r7rs` to Racket and then
include the Scheme stuff. It first needs to `(import (scheme base))`
so that we can use `include` and `export`. The included `.sld` files
import everything else from the Scheme standard that the library
needs.

Note that `lib` depends on `sublib` but `sublib` is not imported by
the `define-library` form in `lib.sld`. Instead, `lib.rkt` has to load
lib *and all its dependencies*: it contains `(include "sublib.sld")`
in addition to the obvious `(include "lib.sld")`.

So `lib.sld` imports only stuff from the Scheme standard whereas
`lib.rkt` imports all our custom libraries. I had to resort to this
hack because I couldn't get the Racket module finder to find `sublib`
if I put it in the `(define-library ...)` imports. I didn't try hard
at all so there may well be a way to make it work.

## Mutable vs immutable lists

Racket uses immutable cons cells (made by Racket's `cons`, satisfies
`pair?`) by default whereas R7RS uses mutable cons cells (made by
Racket's `mcons`, satisfies `mpair?`). That is, when you call `cons`
on the Scheme side, it actually makes something that looks to Racket
as if you had called `mcons` on the Racket side. A mutable cons means
you can use Scheme's `set-car!` and `set-cdr!` to alter it in place,
whereas the car and cdr of an immutable cons can't be changed after
the initial `cons`.

By default, Racket displays lists made out of mutable conses using
`{curly braces}` instead of `(ordinary parentheses)`. This will bite
you when you pass lists over the R7RS--Racket boundary. You can print
using ordinary parentheses by changing the `print-mpair-curly-braces`
parameter but for many things it may be easier to convert your lists
(and trees) from mutable to immutable.

I don't know whether the Racket R7RS shim allows you to make immutable
conses on the Scheme side. It would be nice to have an option for
Scheme `cons` to make immutable conses (in that case `set-car!` and
`set-cdr!` would cause an error, which is fine for code using only
immutable data structures).

## Where to find R7RS libraries

Lots of R7RS libraries are collected by Alex Shinn at
http://snow-fort.org/

## Bottom line

The upshot of all this is that you can mix R7RS and Racket with a
little work and your codebase stays pretty clean (at least for simple
cases).
