(defpackage #:unisig (:export read-unisig write-unisig) (:use cl charset ext))
(in-package #:unisig)

(defconstant +magic+
  (coerce '(#xDC #xDC #x0D #x0A #x1A #x0A #x00)
          '(vector (unsigned-byte 8))))

(defun read-unisig (stream)
  (let ((mag (make-array (length +magic+) :element-type '(unsigned-byte 8))))
    (and (= (length mag) (read-sequence mag stream))
         (equalp +magic+ mag)
         (let* ((lenbyte (read-byte stream nil nil))
                (uuid-p (= 0 lenbyte))
                (len (if uuid-p 16 lenbyte))
                (sig (make-array len :element-type '(unsigned-byte 8))))
           (and (= len (read-sequence sig stream))
                (if uuid-p sig
                    (ext:convert-string-from-bytes sig charset:utf-8)))))))

(defun write-unisig (stream format)
  (let* ((uuid-p (etypecase format
                   (string nil)
                   ((vector (unsigned-byte 8)) t)))
         (sig (if uuid-p format
                  (ext:convert-string-to-bytes format charset:utf-8)))
         (lenbyte (if uuid-p 0 (length sig))))
    (when (and uuid-p (not (= 16 (length format))))
      (error "Bad UUID: ~S" format))
    (write-sequence +magic+ stream)
    (write-byte lenbyte stream)
    (write-sequence sig stream)
    format))
