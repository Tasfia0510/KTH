// rustc bernoulli.rs
// ./bernoulli

fn binom (n: u16 , k: u16) -> f64 {
    //r ← 1
    let mut r = 1.0;
    // for i ← 1 to k do
    for i in 1..=k{
        let i = i as f64;
        let n = n as f64;
        //r ← r · (n − i + 1)/i
        r = r * (n - i + 1.0) / i;
    }
    // return r
    r
}

fn bernoulli (n: usize) -> f64 {
    // PSEUDOKOD B[0] ← 1
    // skapar en vektor med n+1 st 0.0
    let mut b = vec![0.0; n+1];
    b[0] = 1.0;
    //  "PSEUDOKOD for m ← 1 to n do  B[m] <- 0"
    for m in 1..=n {
        // PSEUDOKOD for k ← 0 
        let mut temp = 0.0;
        // for k ← 0 to m − 1 do
        for k in 0..m {
            // B[m] ← B[m] − BINOM(m + 1, k) · B[k
            temp -= binom ((m+1) as u16, k as u16)* b[k];
        }
        // B[m] ← B[m]/(m + 1)
        b[m] = temp / (m + 1) as f64;
    }
    // return B[n]
    b[n]
}

fn main() {
    for n in 0..=9 {
        let result = bernoulli(n);
        println!("B({}) = {}", n, result);
    }
}