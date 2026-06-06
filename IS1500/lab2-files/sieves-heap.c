/*
 sieves.c
 By Tasfia Alam.
 Assignment 3: Arrays 
*/

# include <stdio.h>
# include <stdlib.h>
# include <time.h>

#define COLUMNS 6

// Sieve of Eratosthenes: Assignment 3 - Task 2 (heap)

void print_sieves(int n) {

    // malloc dynamically allocates n number of bytes (uses heap)
    int *a = (int *) malloc(sizeof(int) * n);
    for (int i = 0; i <= n; i++) {
      // 1 if prime, 0 is not prime 
      a[i] = 1;                                          
    }

    // sieve of eratosthenes algorithm 
    // set all non-primes to false with 0 
    for (int i = 2; i * i <= n; i++) {          //skip all the multiples 
      if (a[i] == 1) {
        for (int j = i * i; j <=n; j += i) {
          a[j] = 0; 
        }
      }
    }

    // print all primes (vet ej varför jag får % på slutet)
    for (int i = 2; i <= n; i++) {
      if (a[i]) {

        // function copied from print-primes.c 
        static int counter = 0;                       

        printf("%10d", i);
        counter++; 

        if ((counter % COLUMNS) == 0) {
        printf("\n");

        } 
      }
    }
    printf("\n");
    // release the memory back to the system (because malloc takes memory from the heap)
    free(a);
}

// main copied from print-primes.c 
// 'argc' contains the number of program arguments, and
// 'argv' is an array of char pointers, where each
// char pointer points to a null-terminated string.
int main(int argc, char *argv[]){
    if(argc == 2) {

      clock_t c0 = clock();
      print_sieves(atoi(argv[1]));
      clock_t c1 = clock();

      double seconds = (double) (c1-c0) / CLOCKS_PER_SEC;
      printf("Time: %.2f seconds\n", seconds);

    }
    
  else {
    printf("Please state an integer number.\n");
  }
  return 0;

}
