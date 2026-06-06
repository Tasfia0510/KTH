/*
 pointers.c
 By David Broman.
 Last modified: 2015-09-15
 This file is in the public domain.
*/

// Assignment 4 - Pointers 

#include <stdio.h>
#include <stdlib.h>

// text1 and text2 are pointers and this pointer points to the address of these strings 
char* text1 = "This is a string.";
char* text2 = "Yet another thing.";

// 20 integers 
int list1[20];  
int list2[20];
int counter = 0;  

// copycode functin from assembly 
void copycodes(const char* text, int* list, int* counter) {
  // read a0 (the source string) - get its pointer
  // if src is zero (ends with null-byte), stop (go to done in assembly) 
  // store it in destination 
  // increment src, destination and counter by one (in assembly destination is moved by 4)

  while(*text != '\0') {
    *list = (int)* text;   // store the ASCII value of the character in destination, dereferencing in pointer (follows the pointer to the value), in assembly: lb and sb 
    text++;                // move pointer to the next place in source string (ex: t, h, i, s...)
    list++;              // move pointer to the next integer (from our respective ACII value, ex: 0x054, 0x068...) 
    (*counter)++;          // increment counter by 1, we use *counter because the changes are saved (ändringarna sparas) 
  }

}

// work function from assembly 
void work () {
  // using & to get memory address of counter 
  copycodes(text1, list1, &counter);
  copycodes(text2, list2, &counter);
}

void printlist(const int* lst){
  printf("ASCII codes and corresponding characters.\n");
  while(*lst != 0){
    printf("0x%03X '%c' ", *lst, (char)*lst);
    lst++;
  }
  printf("\n");
}

void endian_proof(const char* c){
  printf("\nEndian experiment: 0x%02x,0x%02x,0x%02x,0x%02x\n", 
         (int)*c,(int)*(c+1), (int)*(c+2), (int)*(c+3));
  
}

int main(void){
 
    work();
    printf("\nlist1: ");
    printlist(list1);
    printf("\nlist2: ");
    printlist(list2);
    printf("\nCount = %d\n", counter);

    endian_proof((char*) &counter);
}
