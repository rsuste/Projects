//
// Created by xsuste11 on 08-Mar-18.
// Eratosthenes.c
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//
//
#include "bit_array.h"
#include <limits.h>
#include <stdio.h>

void Eratosthenes(bit_array_t pole) {
    unsigned long pocet_bitu = bit_array_size(pole); // pocet bitech
    for (unsigned long int i=2;i<pocet_bitu+1;i++) //Pro kazdy bit
    {
        //printf("bit pole: %d\n",(bit_array_getbit(pole,i)));
        if ((bit_array_getbit(pole,i))==0){ //pokud se bit rovna nule
            //printf("found %ld\n",i);
            for (unsigned long j=2;i*j < pocet_bitu+1;j++){ //pojede dokud je nedojede nakonec pole bitu
                bit_array_setbit(pole,i*j,1); // na mocninu bitu na kterem se nasla 0 vlozi !
                //printf("mocnina %d\n",i*j);
            }
        }
    }
}


