//
// Created by Radim Šustek on 22-Apr-18.
// htab_move.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//


#include <stdio.h>
#include "HS_TABLE.h"

htab_t *htab_move(unsigned int newsize,htab_t *t2){
    if (t2 == NULL) // overime zda zadany odkaz je funkcni
    {
        fprintf(stderr,"Byl zadan neplatny ukazatel na tabulku");
        return NULL;
    }
    if (newsize <= 0) // overime zda newsize neni mensi nebo rovna nule
    {
        fprintf(stderr,"Byla zadana velikost mensi nebo rovna 0");
        return NULL;
    }
    htab_t *t1 = htab_init(newsize); // vytvorime novou tabulku
    if (t1 == NULL) // overime zda se vytvoreni povedlo
    {
        fprintf(stderr,"Nepovedla se inicializace nove tabulky");
        return NULL;
    }
    unsigned int velikost = 0;
    if (t1->array_size >= t2->array_size) // v pripade ze je nova velikost vetsi nez ta stara
        velikost = t2->array_size;
    else if (t1->array_size < t2->array_size) //v opacnem pripade ?
        velikost = t1->array_size;
    for (unsigned int i = 0; i < velikost; i++) // vsechny prvky z tabulky t2 se vlozi do t2
        if (t2->list[i] != NULL) // v pripade ze prvek neni null vlozi se do nove tabulky
            t1->list[i]= t2->list[i];
    htab_clear(t2);
    return t1;


}
