"kör koden:   gst bernoulli.st   "

binom := [:n :k |
    "r ← 1"
    |r|
    r := 1 asFraction. 
    "for i ← 1 to k do r ← r · (n − i + 1)/i"
    1 to: k do: [:i | r:= r* (n - i + 1) / i].
    "return r"
    r
].

bernoulli := [:n |
    " PSEUDOKOD B[0] ← 1, dynasmisk array"
    |b|
    b := OrderedCollection new.
    b add: 1 asFraction. 
    "PSEUDOKOD for m ← 1 to n do  B[m] <- 0"
    1 to: n do: [:m |
        b add: 0 asFraction.
        "PSEUDOKOD for k ← 0 to m − 1 do B[m] B[m] BINOM(m + 1, k) B[k]"
        0 to: m - 1 do: [:k |
            b at: m + 1 put: (b at: m + 1) - ((binom value: m + 1 value: k) * (b at: (k + 1)))
        ].
        "PSEUDOKOD B[m] ← B[m]/(m + 1) "
        b at: m + 1 put: (b at: m + 1 ) / (m + 1)
    ]. 
    "return B[n]"
    b at: n + 1 
].

"printa de 10 första"
0 to: 9 do: [:i |
    Transcript  
        showCr: (bernoulli value: i) asString.
].