/*
 print-primes.c
 By David Broman.
 Last modified: 2015-09-15
 This file is in the public domain.
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define COLUMNS 6

// Function copied from prime.c 
int is_prime(int n) {
  if (n <= 1) {                              
    return 0; 
  }
  
  for (int i = 2; i <= sqrt(n); i++) {      
    if ((n % i) == 0)                     
      return 0;                         
    }

    return 1;                        
}

/**
 * Prints in columns (6)
 * n is the number that will be printed
 * void because it does not return any value 
 */

void print_number (int n) {
  // Side effect 'static': is not reset every time its called 
  static int counter = 0;                       

    printf("%10d", n);
    counter++; 

    if ((counter % COLUMNS) == 0) {
      printf("\n");
  }

}

 // Should print out all prime numbers less than 'n'
void print_primes(int n){

    for (int i = 2; i <= n; i++) {
      if (is_prime(i)) {
        print_number(i);
      }
    }
    printf("\n");
  
}

// 'argc' contains the number of program arguments, and
// 'argv' is an array of char pointers, where each
// char pointer points to a null-terminated string.
int main(int argc, char *argv[]){
    if(argc == 2) {

      clock_t c0 = clock();
      print_primes(atoi(argv[1]));
      clock_t c1 = clock();

      double seconds = (double) (c1-c0) / CLOCKS_PER_SEC;
      printf("Time: %.2f seconds\n", seconds);

    }
    
  else {
    printf("Please state an integer number.\n");
  }
  return 0;

}
 
