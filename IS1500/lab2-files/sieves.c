/*
 sieves.c
 By Tasfia Alam.
 Assignment 3: Arrays 
*/

# include <stdio.h>
# include <stdlib.h>
# include <math.h> 
# include <time.h>

#define COLUMNS 6

int total_distance = 0; 
int total_primenumbers = 0; 
int distance_between = 0; 

// Sieve of Eratosthenes: Assignment 3 - Task 1 (stack)

void print_sieves(int n) {
    // local array stored in stack, here all numbers from 0-n will be stored 
    // char gives 1 byte per number (int gives 4)
    char a[n+1];  

    // assume that all numbers in array are primes 
    for (int i = 0; i <= n; i++) {

      //base case 
      if (a[i] == 0 || a[i] == 1) {
        a[i] = 0; 
      }

      // 1 if prime, 0 is not prime 
      a[i] = 1;   
      
    }

    // sieve of eratosthenes algorithm 
    // set all non-primes to false with 0 
    for (int i = 2; i <= sqrt(n); i++) {
      if (a[i] == 1) {
        for (int j = i * i; j <=n; j += i) {
          a[j] = 0; 
        }
      }
    }

    // print all primes 
    for (int i = 2; i <= n; i++) {
      if (a[i]) {
        // function copied from print-primes.c 
        static int counter = 0;              

        printf("%10d", i);
        counter++; 

        if ((counter % COLUMNS) == 0) {
        printf("\n");

        }

        //surprise assessment 
        total_primenumbers++; 
        total_distance = total_distance + distance_between;
        distance_between = 1; 

    }
    else {
      distance_between++; 
    }

  }

}

// main copied from print-primes.c 
// 'argc' contains the number of program arguments, and
// 'argv' is an array of char pointers, where each
// char pointer points to a null-terminated string.
int main(int argc, char *argv[]) {
    if(argc == 2) {

      clock_t c0 = clock();
      print_sieves(atoi(argv[1]));
      clock_t c1 = clock();

      double seconds = (double) (c1-c0) / CLOCKS_PER_SEC;
      printf("Time: %.2f seconds\n", seconds);

    }
    
  else 
    printf("Please state an integer number.\n");
    printf("Average: %f \n", (double) total_distance / total_primenumbers);
  
  return 0;

}

