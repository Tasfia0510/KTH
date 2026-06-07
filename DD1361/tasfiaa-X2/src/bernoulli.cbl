           *> För att köra: cobc -x -free bernoulli.cbl
           *> ./bernoulli
           identification division.
           program-id. bernoulli.

           environment division.
           
           data division. 
           working-storage section.
               01 n    pic 99 value 10. 
               01 m    pic 99 value 0. 
               01 k    pic 99 value 0.
               01 i    pic 99 value 0.

               01 binom-n pic 99 value 0.

               01 r    pic s9(9)v9(9) value 0.
               01 temp pic s9(9)v9(9) value 0.

               01 bern.
                   02 b pic s9(5)v9(9) occurs 11 times value 0.

           procedure division.
               *> PSEUDOKOD B[0] ← 1
               move 1 to b(1) 

               *> PSEUDOKOD for m ← 1 to n do
               perform varying m from 1 by 1 until m > n

                 *> PSEUDOKOD rad 4: B[m] <- 0
                 move 0 to temp
 
                *> PSEUDOKOD for k ← 0 to m − 1 do
                perform varying k from 0 by 1 until k = m

                *> PSEUDOKOD B[m] B[m] BINOM(m + 1, k) B[k]. 
                *> först anropa binom som sparar värdet i r 
                compute binom-n = m + 1 
                perform binom 

                compute temp = temp - r * b(k + 1)
 
                end-perform 
                *> PSEUDOKOD B[m] ← B[m]/(m + 1) 
                compute b(m + 1) = temp/(m + 1)
                *> printa ut 
                display b(m + 1)
               end-perform
               stop run. 
           binom.
           *> r ← 1
           move 1 to r 

           *> for i ← 1 to k do
           perform varying i from 1 by 1 until i > k

           *> r ← r · (n − i + 1)/i
           compute r = r * (binom-n - i + 1) / i

           *> return r
           end-perform 
           exit.
