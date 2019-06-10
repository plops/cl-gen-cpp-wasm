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
	       (include <stdio.h>)
	     
	     (function (foo ((a :type int)
			     (b :type int))
			    int)
		       (return (+ b (* a a))))
	     )))
    (write-source *main-cpp-filename* "c" code)))
