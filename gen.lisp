(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload :cl-cpp-generator))
(in-package :cl-cpp-generator)
(defmacro e (&body body)
  `(statements (<< "std::cout" ,@(loop for e in body collect
				      (cond ((stringp e) `(string ,e))
					    (t e))) "std::endl")))
cl-gen-cpp-wasm 





(progn
  (defparameter *main-cpp-filename*
    (merge-pathnames "stage/cl-gen-cpp-wasm/source/wasm_01"
		     (user-homedir-pathname)))
  (let* ((code
	  `(with-compilation-unit
	       ;(include <stdio.h>)
	     
	     (function (foo ((a :type int)
			     (b :type int))
			    int)
		       (return (+ b (* a a))))
	     )))
    (write-source *main-cpp-filename* "c" code)))
;; 8MB stack
;; clang --target=wasm32 -std=c11 -O3 -flto -nostdlib -Wl,--no-entry -Wl,--export-all -Wl,--lto-O3 -Wl,-z,stack-size=$[8 * 1024 * 1024] -o wasm_01.wasm wasm_01.c

;; clang --target=wasm32 -emit-llvm -c -S wasm_01.c
;; llc -march=wasm32 -filetype=obj wasm_01.ll 
;; asm-ld --no-entry --export-all -o wasm_01.wasm wasm_01.o

;; sudo pacman -S wabt
;; wasm-objdump -x wasm_01.o
;; wasm2wat warm_01.wasm


