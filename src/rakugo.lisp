(in-package #:cl-user)
(defpackage rakugo
  (:use #:cl)
  (:export #:search-performer-schedules))
(in-package #:rakugo)

(define-condition ambiguous-query (error)
  ((query :type string
          :initarg :query)
   (results-count :initarg :results-count
                  :initform nil))
  (:report (lambda (condition stream)
             (with-slots (query results-count) condition
               (format stream "Ambiguous query: '~A'~:[~;~:* (~D result~:*~P)~]"
                       query
                       results-count)))))

(defun matched-performer (query matched-performers)
  (let ((performers
          (remove-if-not (lambda (name)
                           (or (search query name)
                               (search query (ppcre:regex-replace-all "\\s" name ""))))
                         matched-performers
                         :key #'rakugo.class:performer-name)))
    (cond
      (performers
       (when (cdr performers)
         (error 'ambiguous-query
                :query query
                :results-count (length performers)))
       (first performers))
      (matched-performers
       (when (cdr matched-performers)
         (error 'ambiguous-query
                :query query
                :results-count (length matched-performers)))
       (first matched-performers)))))

(defun search-performer-schedules (query)
  (let ((performer
          (matched-performer query (rakugo.org.rakugo:search-performers query))))
    (when performer
      (return-from search-performer-schedules
        (cons performer (rakugo.org.rakugo:performer-schedules performer)))))
  (let ((performer
          (matched-performer query (rakugo.org.geikyo:search-performers query))))
    (when performer
      (return-from search-performer-schedules
        (cons performer (rakugo.org.geikyo:performer-schedules performer)))))
  (error "Not found: '~A'" query))
