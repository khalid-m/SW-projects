;; Transactional PUT - REMOVE on MEXIMA
(defglobal _mexima-put_ (new-event '/mexima-put '/mexima-put-undo nil)
  "History event for /MEXIMA-PUT")

(defun /mexima-put (k mx v)
  "Transactional MEXIMA-PUT"
  (history-add _mexima-put_ k  mx (mexima-get k mx) v)
  (mexima-put k mx v))

(defun /mexima-put-undo (k mx old new)
  "Rollback of /MEXIMA-PUT"
  (if old (mexima-put k mx old)
    (mexima-delete k mx)))

(defglobal _mexima-delete_ (new-event '/mexima-delete '/mexima-delete-undo nil)
  "History event for /MEXIMA-DELETE")

(defun /mexima-delete (k mx)
  "Transactional MEXIMA-DELETE"
  (history-add _mexima-delete_ k  mx (mexima-get k mx) nil)
  (mexima-delete k mx))

(defun /mexima-delete-undo (k mx old new)
  "Rollback of /MEXIMA-DELETE"
  (if old (mexima-put k mx old)))

(defun /put-btree    (k mx v) (/mexima-put k mx v))
(defun /delete-btree (k mx) (/mexima-delete k mx))