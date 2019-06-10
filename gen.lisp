(eval-when (:compile-toplevel :execute :load-toplevel)
  (mapc #'ql:quickload `("cl-cpp-generator"
			 "cl-js-generator"
			 "cl-who"
			 "clack")))


(defparameter *clack-handler* (lambda (env)
				(declare (ignorable env))
				`(200 (:content-type "text/plain")
				      ("Hello Clack!"))))


(defparameter *clack-server*
   (clack:clackup (lambda (env)
		    (funcall *clack-handler* env))))


(setq cl-who:*attribute-quote-char* #\")
(setf cl-who::*html-mode* :html5)


(let ((script-str (cl-js-generator::beautify-source
	       `(let-g ((bla 3))))))
  (setf
    *clack-handler*
      (lambda (env)
	(destructuring-bind (&key server-name remote-addr path-info remote-port &allow-other-keys) env
	  (cond
	    ((string= "/" path-info)
	     `(200 (:content-type "text/html; charset=utf-8")
		   (,(cl-who:with-html-output-to-string (s)
		       (cl-who:htm
			(:html
			 (:head (:meta :charset "utf-8"))
			 (:body (:h1 "test2")
				(:script :type "text/javascript"
					 (princ script-str s))))))))))
	  )))
  )



(in-package :cl-cpp-generator)
(defmacro e (&body body)
  `(statements (<< "std::cout" ,@(loop for e in body collect
				      (cond ((stringp e) `(string ,e))
					    (t e))) "std::endl")))




(progn
  (defparameter *main-cpp-filename*
    (merge-pathnames "stage/cl-gen-cpp-wasm/source/wasm_01"
		     (user-homedir-pathname)))
  (let* ((code
	  `(with-compilation-unit
					;(include <stdio.h>)

	       (raw "extern unsigned char __heap_base;")

	     (decl ((g_bump_pointer :type "unsigned int"
				    :init &__heap_base)))
	     (function (malloc ((n :type int))
			       void*)
		       (let ((r :type "unsigned int" :init g_bump_pointer)
			     )
			 (setf bump_pointer (+ bump_pointer n))
			 (return (cast void* r))))
	     
	     (function (foo ((a :type int)
			     (b :type int))
			    int)
		       (return (+ b (* 2 a a)))))))
    (write-source *main-cpp-filename* "c" code)
    (sb-ext:run-program "/usr/bin/clang"
			`("--target=wasm32"
			  "-std=c11"
			  "-O3" "-flto" "-nostdlib"
			  "-Wl,--no-entry"
			  "-Wl,--export-all"
			  "-Wl,--lto-O3"
			  ,(format nil "-Wl,-z,stack-size=~a"
				   (* 8 1024 1024))
			  "-o"
			  "/home/martin/stage/cl-gen-cpp-wasm/source/wasm_01.wasm"
			  "/home/martin/stage/cl-gen-cpp-wasm/source/wasm_01.c"))))
;; 8MB stack
;; clang --target=wasm32 -std=c11 -O3 -flto -nostdlib -Wl,--no-entry -Wl,--export-all -Wl,--lto-O3 -Wl,-z,stack-size=$[8 * 1024 * 1024] -o wasm_01.wasm wasm_01.c

;; clang --target=wasm32 -emit-llvm -c -S wasm_01.c
;; llc -march=wasm32 -filetype=obj wasm_01.ll 
;; asm-ld --no-entry --export-all -o wasm_01.wasm wasm_01.o

;; sudo pacman -S wabt
;; wasm-objdump -x wasm_01.o
;; wasm2wat warm_01.wasm


