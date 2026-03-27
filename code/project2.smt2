;; Lineární aritmetika + neinterpretované funkce
(set-logic UFLIA)

(set-option :produce-models true)


;; ====================
;; DEKLARACE PREDIKATU
;; ====================

;; Predikát "identifikátor je proces"
(declare-fun is_process (Int) Bool)

;; Predikát "identifikátor je zdroj"
(declare-fun is_resource (Int) Bool)

;; Predikát "proces vlastní zdroj"
(declare-fun owns (Int Int) Bool)

;; Predikát "proces je pozastaven a čeká na zdroj"
(declare-fun requests (Int Int) Bool)

;; Predikát popisující množinu procesů, pro které je
;; ověřováno zda nastal deadlock
(declare-fun in_deadlock (Int) Bool)

(define-fun example () Bool
  ; Pro každý identifikátor ...
  (forall ((i Int))
    ; ... platí, že buď ...
    (or
      ; ... není proces ...
      (not (is_process i))
      ; ... nebo není zdroj.
      (not (is_resource i))
    )
  )
)

;; ==================
;; START OF SOLUTION
;; ==================

; XLOGIN: xknotem00

;; Formule 1
;; Pokud dva procesy sdili zdroje, musi se jednat o stejny proces
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
;; Mnozina procesu ma minimum a maximum
(define-fun finitely_many_processes () Bool
  ; existuji p_max a p_min
  (exists ((p_max Int)(p_min Int))
    ; ktere jsou procesy a ...
    (and
      (is_process p_max)
      (is_process p_min)
      ; pro vsechny x
      (forall ((x Int))
        (=>
          ; pokud x je proces
          (is_process x)
          ; potom x lezi v rozsahu <p_min; p_max>
          (and
            (<= x p_max)
            (>= x p_min)
          )
        )
      )
    )
  ) 
)

;; Formule 3
;; existuje proces v deadlocku a
;; pro vsechny procesy v deadlocku existuje proces v deadlocku,
;; ktery drzi soubor na ktery cekaji
(define-fun has_deadlock () Bool
  (and
    ;existuje x ktere je procesem v dedlocku
    (exists ((x Int))
      (and
        (is_process x)
        (in_deadlock x)
      )
    )
    ; pro vsechna p
    (forall ((p Int))
      ; pokud
      (=>
        ; p je proces v deadlocku
        (and
          (is_process p)
          (in_deadlock p)
        )
        ; potom existuje r a o takove ze
        (exists ((r Int)(o Int))
          ; r je zdroj na ktery ceka p a o je vlastnikem souboru v deadlocku
          (and
            (is_resource r)
            (requests p r)
            (is_process o)
            (owns o r)
            (in_deadlock o)
          )
        )
      )
    )
  )
)

;; ==================
;; END OF SOLUTION
;; ==================

; Základní testy ověřující, že podmínky jsou splnitelné

(set-info :status sat)
(check-sat-assuming (exclusive_resources))

(set-info :status sat)
(check-sat-assuming (finitely_many_processes))

(set-info :status sat)
(check-sat-assuming (has_deadlock))
