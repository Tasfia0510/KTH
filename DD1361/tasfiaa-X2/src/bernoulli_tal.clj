; För att köra: clojure -M bernoulli_tal.clj

(defn binom [n k]
    ; PSEUDOKOD r←1, for i←1 to k do
    (reduce (fn [r i]
        ; PSEUDOKOD r←r·(n−i+ 1)/i
        (* r (/ (+ (- n i) 1) i)))
        1 (range 1 (inc k))))

(defn B[n]
    ; PSEUDOKOD B[0] ←1
    (let [B0 [1]]
    ; PSEUDOKOD for m←1 to n do
        (loop [m 1, bernoulli_nums B0]
            (if (> m n)
            (nth bernoulli_nums n)
            (let [
                ; PSEUDOKOD B[m] ← 0
                bm0 0
                ; PSEUDOKOD for k←0 to m−1 do
                k (range 0 m)
                ; PSEUDOKOD B[m] ←B[m]−BINOM(m+ 1,k)·B[k]
                ; reduce går igenom listan och bygger upp
                sum (reduce (fn [ack k]
                            (- ack (* (binom (+ m 1) k)
                                      (nth bernoulli_nums k))))
                            bm0 k)
                ; PSEUDOKOD B[m] ←B[m]/(m+ 1)
                bm (/ sum (+ m 1))]
                ; conjure lägger till element på slutet (nytt därav immutable)
            (recur (+ m 1) (conj bernoulli_nums bm)))))))
        
; printa de 10 första bernoulli talen
(doseq [i (range 10)]
    (println (str "B(" i ") = "(B i))))


; Clojures egenskaper:
; - Funktionellt språk
; - Lisp syntax (träd av massor av paranteser)
; - Paradigm: dynamiskt och funktionell (immutable)
; - loop definerar startvärden för rekursion, recur hoppar tillbaka till funktionen (rekursion)
; - let skapar variabler, oföränderliga