(eval-when (:compile-toplevel :execute :load-toplevel)
  (mapc #'ql:quickload `("cl-cpp-generator"
			 "cl-js-generator"
			 "cl-who"
			 "clack")))


(defparameter *clack-handler* (lambda (env)
				(declare (ignorable env))
				(format t "start-handler~%")
				
				`(200 (:content-type "text/plain")
				      ("Hello Clack!"))))
(defun call-clack-handler (env)
  (funcall *clack-handler* env))

(defparameter *clack-server*
   (clack:clackup #'call-clack-handler))


(setq cl-who:*attribute-quote-char* #\")
(setf cl-who::*html-mode* :html5)


(let ((script-str (cl-js-generator::beautify-source
		   `(do0
		     "async "
		     (def init ()
		       (return 0))))))
  (setf
    *clack-handler*
    (lambda (env)
      (format t "new-handler2 ~a~%" env)
	(destructuring-bind (&key server-name remote-addr path-info remote-port &allow-other-keys) env
	  (cond
	    ((string= "/" path-info)
	     `(200 (:content-type "text/html; charset=utf-8")
		   ("<!DOCTYPE html>

<script type="module">
  async function init() {
    const { instance } = await WebAssembly.instantiateStreaming(
      fetch(\"./wasm_10.wasm\")
    );

    const jsArray = [1, 2, 3, 4, 5];
    // Allocate memory for 5 32-bit integers
    // and return get starting address.
    const cArrayPointer = instance.exports.malloc(jsArray.length * 4);
    // Turn that sequence of 32-bit integers
    // into a Uint32Array, starting at that address.
    const cArray = new Uint32Array(
      instance.exports.memory.buffer,
      cArrayPointer,
      jsArray.length
    );
    // Copy the values from JS to C.
    cArray.set(jsArray);
    // Run the function, passing the starting address and length.
    console.log(instance.exports.sum(cArrayPointer, cArray.length));
  }
  init();
</script>
"
      #+nil,(cl-who:with-html-output-to-string (s)
		       (cl-who:htm
			(:html
			 (:head (:meta :charset "utf-8"))
			 (:body (:h1 "test2")
				(:script :type "module"
					 (princ script-str s)))))))))
	    (t
	     `(200 (:content-type "text/html; charset=utf-8")
		   (,(cl-who:with-html-output-to-string (s)
		       (cl-who:htm
			(:html
			 (:head (:meta :charset "utf-8"))
			 (:body (:h1 "error")))))))))))))



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
			 (setf g_bump_pointer (+ g_bump_pointer n))
			 (return (cast void* r))))
	     
	     (function (foo ((a :type int)
			     (b :type int))
			    int)
		       (return (+ b (* 2 a a))))
	     (function (sum ((a :type int*)
			     (len :type int))
			    int)
		       (let ((sum :type int :init 0))
			 (dotimes (i len)
			      (setf sum (+ sum (aref a i))))
			 (return sum))))))
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


