#|
  This file is a part of rakugo project.
  Copyright (c) 2016 Eitaro Fukamachi (e.arrows@gmail.com)
|#

#|
  Author: Eitaro Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage rakugo-asd
  (:use :cl :asdf))
(in-package :rakugo-asd)

(defsystem rakugo
  :version "0.1"
  :author "Eitaro Fukamachi"
  :license "BSD 2-Clause"
  :depends-on (:dexador
               :plump
               :clss
               :quri
               :cl-ppcre
               :local-time)
  :components ((:module "src"
                :components
                ((:file "rakugo" :depends-on ("org"))
                 (:module "org"
                  :depends-on ("class" "util")
                  :components
                  ((:file "rakugo")
                   (:file "geikyo")))
                 (:file "class" :depends-on ("util"))
                 (:file "util"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op rakugo-test))))
