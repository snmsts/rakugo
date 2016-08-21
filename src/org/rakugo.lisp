(in-package #:cl-user)
(defpackage rakugo.org.rakugo
  (:use #:cl
        #:rakugo.util
        #:rakugo.class)
  (:import-from #:ppcre
                #:scan
                #:scan-to-strings
                #:register-groups-bind)
  (:import-from #:local-time
                #:parse-timestring)
  (:import-from #:dexador)
  (:import-from #:plump
                #:parse
                #:get-attribute
                #:get-elements-by-tag-name
                #:text)
  (:import-from #:clss
                #:select)
  (:import-from #:quri
                #:make-uri
                #:uri-path
                #:uri
                #:merge-uris)
  (:export #:search-performers
           #:performer-schedules))
(in-package #:rakugo.org.rakugo)

(defun make-rakugo-schedule (&rest args &key url title)
  (cond
    ((ppcre:scan "^/jyoseki/" (quri:uri-path url))
     (ppcre:register-groups-bind (hall month period time)
         ("^([^ 　]+)[ 　]+?(\\d{0,1})月(上|中|下)席\\s+?(昼|夜)席$" title)
       (unless hall
         (error "Unexpected schedule title: '~A'" title))
       (setf period
             (cond
               ((string= period "上")
                :beginning)
               ((string= period "中")
                :mid)
               ((string= period "下")
                :late)))
       (apply #'make-jyoseki-schedule
              :title (format nil "~A ~A月~A" hall month
                             (ecase period
                               (:beginning "上席")
                               (:mid "中席")
                               (:late "下席")))
              :hall hall
              :month (parse-integer month)
              :period period
              :time (if (string= time "昼")
                        :daytime
                        :night)
              args)))
    (t
     (apply #'make-schedule
            :date (let ((body (plump:parse (dex:get url))))
                    (local-time:parse-timestring
                     (format nil "~AT~A:00+09:00"
                             (plump:text (select-one ".Span .confirm-text" body))
                             (plump:text (select-one ".StartEvent .confirm-text" body)))
                     :date-separator #\/))
            args))))

(defun search-performers (query)
  (let* ((url (quri:make-uri :defaults "http://rakugo-kyokai.jp/variety-entertainer/member_search.php"
                             :query `(("word" . ,query)
                                      ("x" . 0)
                                      ("y" . 0))))
         (body (plump:parse (dex:get url))))
    (map 'list
         (lambda (row)
           (make-performer
            :name (trim-spaces (plump:text row))
            :org "落語協会"
            :url (quri:merge-uris
                  (quri:uri (plump:get-attribute row "href"))
                  url)))
         (clss:select ".member-list .name" body))))

(defun performer-schedules (performer)
  (let ((body (plump:parse (dex:get (performer-url performer)))))
    (mapcar (lambda (row)
              (let ((url (quri:merge-uris (quri:uri (plump:get-attribute row "href"))
                                          (performer-url performer))))
                (ppcre:register-groups-bind (title)
                    ("^(?:\\d{4}/\\d{2}/\\d{2})?\\s*(.+?)\\s*?\\[詳細\\]$" (plump:text row))
                  (unless title
                    (error "Unexpected link title: '~A'" (plump:text row)))
                  (make-rakugo-schedule
                   :title title
                   :url url))))
            (nreverse
             (plump:get-elements-by-tag-name
              (select-one ".member-detail .inner > .table" body 1)
              "a")))))
