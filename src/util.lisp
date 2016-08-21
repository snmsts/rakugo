(in-package #:cl-user)
(defpackage rakugo.util
  (:use #:cl)
  (:import-from #:clss
                #:select)
  (:export #:trim-spaces
           #:jyoseki-time
           #:select-one))
(in-package #:rakugo.util)

(defun trim-spaces (string)
  (check-type string string)
  (string-trim '(#\Space #\Tab #\Newline #\Return) string))

(defvar *jyoseki-time*
  '(("鈴本演芸場" . ("12:30" "17:30"))
    ("新宿末廣亭" . ("12:00" "17:00"))
    ("浅草演芸ホール" . ("11:40" "16:40"))
    ("池袋演芸場" . ("12:30" "16:45"))
    ("国立演芸場" . ("12:45" "17:45"))))

(defun jyoseki-time (hall daytime-or-night)
  (let ((time (cdr (assoc hall *jyoseki-time* :test #'string=))))
    (unless time
      (error "Invalid hall name: '~A'" hall))
    (let ((time
            (ecase daytime-or-night
              (:daytime
               (first time))
              (:night
               (second time)))))
      (values (parse-integer time :end 2)
              (parse-integer time :start 3)))))

(defun select-one (selector element &optional (index 0))
  (let ((res (clss:select selector element)))
    (if (< index (length res))
        (aref res index)
        nil)))
