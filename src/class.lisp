(in-package #:cl-user)
(defpackage rakugo.class
  (:use #:cl
        #:rakugo.util)
  (:import-from #:local-time
                #:encode-timestamp
                #:timestamp-month
                #:timestamp-year
                #:today)
  (:export #:performer
           #:make-performer
           #:performer-name
           #:performer-org
           #:performer-url

           #:schedule
           #:make-schedule
           #:schedule-title
           #:schedule-date
           #:schedule-url

           #:jyoseki-schedule
           #:make-jyoseki-schedule
           #:jyoseki-schedule-hall
           #:jyoseki-schedule-month
           #:jyoseki-schedule-period
           #:jyoseki-schedule-time

           #:schedule=))
(in-package #:rakugo.class)

(defstruct performer
  name
  org
  url)

(defstruct schedule
  title
  date
  url)

(defstruct (jyoseki-schedule (:include schedule)
                             (:constructor %make-jyoseki-schedule))
  hall
  month
  period
  time)

(defun make-jyoseki-schedule (&rest args &key title hall url month date period time)
  (apply #'%make-jyoseki-schedule
         :title title
         :hall hall
         :url url
         :month month
         :period period
         :time time
         :date (or date
                   (multiple-value-bind (hour min)
                       (jyoseki-time hall time)
                     (let ((this-month (local-time:timestamp-month (local-time:today)))
                           (this-year  (local-time:timestamp-year (local-time:today))))
                       (local-time:encode-timestamp
                        0 0 min hour
                        (ecase period
                          (:beginning 1)
                          (:mid 11)
                          (:late 21))
                        month
                        (if (< month this-month)
                            (1+ this-year)
                            this-year)))))
         args))

(defun schedule= (schedule1 schedule2)
  (block nil
    (unless (eq (type-of schedule1)
                (type-of schedule2))
      (return nil))

    (when (quri:uri= (schedule-url schedule1)
                     (schedule-url schedule2))
      (return t))

    (when (equal (schedule-title schedule1)
                 (schedule-title schedule2))
      (return t))))
