(define-library (sublib)
  (export get-greeting)
  (import (scheme base))
  (include "sublib.scm"))
