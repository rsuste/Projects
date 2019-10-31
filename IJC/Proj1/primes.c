// primes.c
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//


#include <stdio.h>
#include "bit_array.h"
#include "Eratosthenes.h"
#include <limits.h>

//220000000
int main() {
    bit_array_create(test,220000000);
    unsigned long velikost = bit_array_size(test);
    Eratosthenes(test);
    int poc = 9;
    unsigned long prime_numbers[10];

    //vytisknuti posledni 10 prvocisel
    for (unsigned long i=velikost;poc>=0;i--)
    {
        if((bit_array_getbit(test,i))== 0)
        {
            prime_numbers[poc]=i;
            poc--;
        }
    }
    for (unsigned long i = 0;i<10;i++)
        printf("%ld: %ld\n",i+1,prime_numbers[i]);


    return 0;

}
