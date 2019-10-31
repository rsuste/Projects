//
// Created by Radim Šustek on 22-Apr-18.
// hash_free.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <stdlib.h>
#include "HS_TABLE.h"





void htab_free(htab_t *t)
{
    htab_clear(t); // zavolam funkci ktera vynuluje vsechny prvky
    free(t); // uvolnim tabulku

}

