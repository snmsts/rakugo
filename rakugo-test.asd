#|
  This file is a part of rakugo project.
  Copyright (c) 2016 Eitaro Fukamachi (e.arrows@gmail.com)
|#

(in-package :cl-user)
(defpackage rakugo-test-asd
  (:use :cl :asdf))
(in-package :rakugo-test-asd)

(defsystem rakugo-test
  :author "Eitaro Fukamachi"
  :license "BSD 2-Clause"
  :depends-on (:rakugo
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "rakugo"))))
  :description "Test system for rakugo"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
