<?php

/**
 * För att köra: php bernoulli_tal.php
 */

// räknar vilken bernoulli tal vi vill ha, B(0)=1, B(1)=0.5 etc
function B (int $n) {
    // startvärde 
    $B[0] = 1;

    // yttre loop: ger oss nytt bernoulli tal (till n)
    for ($m = 1; $m <= $n; $m++) {
        // nollställer efter varje varv
        $B[$m] = 0;
        
        for ($k = 0; $k <= $m - 1; $k++) {
            $B[$m] = $B[$m] - BINOM($m + 1, $k) * $B[$k];
        }

        $B[$m] = $B[$m] / ($m + 1);
    }
    return $B[$n];
}

// beräknar alla olika sätt man kan välja k element ur n (n k)
function BINOM (int $n, int $k) {
    $r = 1; 

    for ($i = 1; $i <= $k; $i++) {
            $r = $r * ($n - $i + 1) / $i;
    }

    return $r;
}

// printa ut de 10 första bernoulli talen, B(0) till B(9)
for ($i = 0; $i < 10; $i++) {
    $numbers = B($i);
    echo "B($i) = $numbers\n";
}

// kommentar: php har loopar och arrays, är föränderligt
?>
