/*
 prime.c
 By David Broman.
 Last modified: 2015-09-15
 This file is in the public domain.
*/

#include <stdio.h>
#include <math.h>

/**
 * Assignment 1 - Basic Control-Flow 
 * 
 * Return 1 if given integer n is a prime, otherwise returns 0
 * 
 * @note 1 does not count as a prime number (has exactly one factor)
 */
int is_prime(int n) {

  if (n <= 1) {                              // base case 
    return 0; 
  }

  for (int i = 2; i <= sqrt(n); i++) {       // loop until sqrt(n), condition when checking prime numbers (basmatte) for efficiency (faster execution time)
    if ((n % i) == 0)                        // tests its divisiblity 
      return 0;                              // is not prime, therefore returns 0   
    }

    return 1;                                // else return 1 (it is a prime)
}

// Tests for checking prime function 
int main(void){
  printf("%d\n", is_prime(11));  // 11 is a prime.      Should print 1.
  printf("%d\n", is_prime(383)); // 383 is a prime.     Should print 1.
  printf("%d\n", is_prime(987)); // 987 is not a prime. Should print 0.
}



