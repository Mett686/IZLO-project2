(set-logic UFLIA)
(set-info :status unsat)

(declare-fun is_resource (Int) Bool)
(declare-fun requests (Int Int) Bool)
(declare-fun owns (Int Int) Bool)
(declare-fun in_deadlock (Int) Bool)

(define-fun is_process ((p Int)) Bool
  (distinct p 0)
)

;; START OF SOLUTION
;; ==================

; XLOGIN: xknotem00

;; Formule 1
(define-fun exclusive_resources () Bool
  ; Pro vsechny
  (forall ((r Int) (p1 Int) (p2 Int))
    ; Pokud
    (=>
      ; r je zdroj a p jsou procesy ktere vlastni r
      (and
        (is_resource r)
        (is_process p1)
        (is_process p2)
        (owns p1 r)
        (owns p2 r)
      )
      ; tak potom p1 a p2 jsou totozne
      (= p1 p2)
    )
  )
)

;; Formule 2
(define-fun finitely_many_processes () Bool
  ; Existuje takove p_max
  (exists ((p_max Int))
    ; ktere je proces a ...
    (and
      (is_process p_max)
      ; pro vsechny ostatni x
      (forall ((x Int))
        (=>
          ; pokud x je proces a x neni p_max
          (and
            (is_process x)
            (not(= p_max x))
          )
          ; potom x je mensi nez p_max
          ( < x p_max)
        )
      )
    )
  )
)

;; Formule 3
(define-fun has_deadlock () Bool
  ; pro vsechna p
  (forall ((p Int))
    ; pokud
    (=>
      ; p je proces v deadlocku
      (and
        (is_process p)
        (in_deadlock p)
      )
      ; potom pro vsechna r
      (forall ((r Int))
        ; pokud
        (=>
          ; r je zdroj na ktery ceka p
          (and
            (is_resource r)
            (requests p r)
          )
          ; potom existuje o
          (exists ((o Int))
            ; takove ze o je proces v deadlocku ktery vlastni r
            (and
              (is_process o)
              (in_deadlock o)
              (owns o r)
            )
          )
        )
      )
    )
  )
)

;; ==================
;; END OF SOLUTION

(assert finitely_many_processes)

(check-sat)
