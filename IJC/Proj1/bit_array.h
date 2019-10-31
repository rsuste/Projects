//
// Created by xsuste11 on 07-Mar-18.
// bit_array.h
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//

#ifndef IJC_PROJ_1_BIN_ARRAY_H
#define IJC_PROJ_1_BIN_ARRAY_H

#include <limits.h>
#include "error.h"

typedef unsigned long bit_array_t[];

//velikost unsigned long
#define vel_long (sizeof(unsigned long)*CHAR_BIT)
//vytvori pole, o velikosti zadane/pocet bytu
#define bit_array_create(jmeno_pole,velikost) unsigned long jmeno_pole[(((velikost) / (vel_long))+((velikost) % (vel_long) > 0 ? 3 : 2))] = {velikost,0,}

//vrati velikost pole kterou mame ulozenou na pozici jmeno_pole[0]
#define bit_array_size(jmeno_pole) jmeno_pole[0]

//nastavi bit na danou pozici, jelikoz je na 0lte pozici ulozena velikost pole v bitech tak k indexu pole pricitame 1
#define bit_array_setbit(jmeno_pole,index,vyraz) jmeno_pole[(((index)/vel_long)+1)] |= ((vyraz) << (((index)%vel_long)+1))
//nacte 1 nebo 0 ktera je na zadane pozici
#define bit_array_getbit(jmeno_pole,index) ((index)>(jmeno_pole)[0])?(error_exit("byl zadan prilis velky index"),0) : ((jmeno_pole)[(((index)/vel_long)+1)] & ((unsigned long)1 << (((index)%vel_long)+1)))

//inline funkce dodelat + osetrit kritycke pripady(zjistit jake mohou nastat)
static inline unsigned long bitarrazsize(bit_array_t jmeno_pole) {
    return jmeno_pole[0];
}
//mozny problem s funkcnosti
static inline unsigned long bitarraygetbit(const bit_array_t jmeno_pole, unsigned long index){
    if(index > jmeno_pole[0])
        error_exit("byl zadan index vetsi nez velikost pole\n");
    else
    	return jmeno_pole[((index/vel_long)+1)] & ((unsigned long)1 << ((index % vel_long)+1));
}
static inline unsigned long bitarraysetbit(bit_array_t jmeno_pole,unsigned long index, unsigned long vyraz){
    if(index > jmeno_pole[0])
	    error_exit("byl zadan index vetsi nez velikost pole\n");
    else
	    return jmeno_pole[((index/vel_long)+1)] |= (vyraz << ((index%vel_long)+1));
}



#endif //IJC_PROJ_1_BIN_ARRAY_H
