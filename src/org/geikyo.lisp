(in-package #:cl-user)
(defpackage rakugo.org.geikyo
  (:use #:cl
        #:rakugo.util
        #:rakugo.class)
  (:import-from #:dexador)
  (:import-from #:quri
                #:make-uri
                #:uri
                #:merge-uris)
  (:import-from #:plump
                #:parse
                #:get-elements-by-tag-name
                #:get-attribute
                #:text)
  (:import-from #:clss
                #:select)
  (:import-from #:quri
                #:uri
                #:make-uri
                #:merge-uris)
  (:import-from #:ppcre
                #:register-groups-bind)
  (:import-from #:local-time
                #:encode-timestamp
                #:timestamp-month
                #:timestamp-year
                #:today)
  (:export #:search-performers
           #:performer-schedules))
(in-package #:rakugo.org.geikyo)

(defun search-performers (query)
  (let* ((url (quri:make-uri :defaults "http://geikyo.com/profile/index.php"
                             :query `(("keyword" . ,query))))
         (body (plump:parse (dex:get url)))
         (rows (clss:select "#MainCont table tr" body)))
    (loop for i from 1
          while (< i (length rows))
          for row = (aref rows i)
          for el = (select-one "td a" (aref rows i))
          collect (make-performer
                   :name (plump:text el)
                   :org "落語芸術協会"
                   :url (quri:merge-uris
                         (quri:uri (plump:get-attribute el "href"))
                         url)))))

(defun performer-schedules (performer)
  (let* ((body (plump:parse (dex:get (performer-url performer))))
         (jyoseki-rows
           (clss:select "#JyosekiSchedule li" body))
         (rakugo-rows
           (clss:select "#RakugoSchedule li" body)))
    (append
     (loop for row across jyoseki-rows
           for hall = (plump:text (select-one "span a" row))
           for title = (select-one "a" row 1)
           collect
           (ppcre:register-groups-bind (period (#'parse-integer month)
                                               (#'parse-integer start-day)
                                               (#'parse-integer end-day))
               ("^.月(.+)\\s(\\d+)月(\\d+)日〜(\\d+)日$" (plump:text title))
             (declare (ignore start-day end-day))
             (make-jyoseki-schedule
              :title (format nil "~A ~A月~A" hall month period)
              :hall hall
              :url (quri:merge-uris (quri:uri (plump:get-attribute title "href"))
                                    (performer-url performer))
              :month month
              :date (multiple-value-bind (hour min)
                        (jyoseki-time hall :daytime)
                      (let ((this-month (local-time:timestamp-month (local-time:today)))
                            (this-year  (local-time:timestamp-year (local-time:today))))
                        (local-time:encode-timestamp
                         0 0 min hour
                         start-day month 
                         (if (< month this-month)
                             (1+ this-year)
                             this-year))))
              :period (cond
                        ((search "上席" period)
                         :beginning)
                        ((search "中席" period)
                         :mid)
                        ((search "下席" period)
                         :late))
              ;; TODO
              :time :daytime)))
     (loop for row across rakugo-rows
           for a = (first (plump:get-elements-by-tag-name row "a"))
           collect
           (let ((url (quri:merge-uris (quri:uri (plump:get-attribute a "href"))
                                       (performer-url performer))))
             (make-schedule
              :title (plump:text a)
              :date (let* ((body (plump:parse (dex:get url)))
                           (rows (clss:select "#MainCont table td" body)))
                      (ppcre:register-groups-bind ((#'parse-integer year)
                                                   (#'parse-integer month)
                                                   (#'parse-integer day))
                          ("(\\d{4})年(\\d{1,2})月(\\d{1,2})日" (plump:text (aref rows 2)))
                        (ppcre:register-groups-bind ((#'parse-integer hour)
                                                     (#'parse-integer min))
                            ("(\\d{1,2}):(\\d{2})" (plump:text (aref rows 3)))
                          (local-time:encode-timestamp
                           0 0 min hour
                           day month year))))
              :url url))))))
