# Hashids

Common Lisp system to generate YouTube-like hashes from one or many numbers. 
Use hashids when you do not want to expose your database ids to the user.

## Installation

This system can be installed from [UltraLisp](https://ultralisp.org/) like this:

```lisp
(ql-dist:install-dist "http://dist.ultralisp.org/"
                      :prompt nil)
(ql:quickload "hashids")
```

## Usage

```common-lisp
(defvar *id* (hashids:encode 1 2 3)) ; o2fXhV
(hashids:decode *id*) ; (1 2 3)
```

Making your output ids unique:

```common-lisp
(let ((hashids:*salt* "My Project"))
  (hashids:encode 1 2 3)) ; Z4UrtW

(let ((hashids:*salt* "My Other Project"))
  (hashids:encode 1 2 3)) ; gPUasb
```

Use padding to make your output ids longer:

```common-lisp
(hashids:encode 1) ; jR

(let ((hashids:*min-hash-length* 10))
  (hashids:encode 1)) ; VolejRejNm
```

Using a custom alphabet:

```common-lisp
(let ((hashids:*alphabet* "abcdefghijklmnopqrstuvwxyz"))
  (hashids:encode 1 2 3)) ; mdfphx
```

## Curse words! #$%@

This code was written with the intent of placing the output ids in visible places, like the URL. Therefore, the algorithm tries to avoid generating most common English curse words by generating ids that never have the following letters next to each other:

```
c, f, h, i, s, t, u
```
