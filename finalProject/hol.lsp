(setf g1 '((1 2) (2 4) (4 3) (3 1) (1 4) (3 2)))
; This graph is completely connected. You’d test this by calling:
; (completelyConnectedGraph 4 g1)
; and should get back t
(setf g2 '((1 2) (3 4) (4 1) (2 3)))
; This graph is NOT completely connected You’d test this by calling:
; (completelyConnectedGraph 4 g2)
; and should get back nil

(defun completelyConnectedGraph (vert list)
    (if ( = (length list) (/ (* vert (- vert 1)) 2))
        (format t "t")
            (format t "nil")
    
    )
    (values)
)
