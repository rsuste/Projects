//
// Created by Radim Šustek on 18-Apr-18.
// hash_table_init.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//
#include <malloc.h>
#include <stdio.h>
#include "HS_TABLE.h"

//zjistit jak se urcuje velikost tabulky
unsigned int htab_hash_function(const char *str)
{
    unsigned int h=0;     // 32bit
    const unsigned char *p;
    for(p=(const unsigned char*)str; *p!='\0'; p++)
        h = 65599*h + *p;
    return h;
}

htab_t *htab_init(unsigned int size)
{
    //vytvorim tabulku schopnou obsahnout az x slov
    htab_t *table = malloc(size*sizeof(struct htab_listitem)+ sizeof(struct HS_table)); // naalokuji velikost pocet itemu a velikost table
    if (table == NULL){ // zda se maloc nepovedl
        fprintf(stderr, "Nepovedl se malloc");
        return NULL;
    }
    table->array_size = size;//velikost array // nastavim velikost flexible array
    table->size=0; // pocet slov // a do poctu slov dam 0

    for (long long int i = 0;i<size;i++) //vynuluje vsechny prvky tabulky
        table->list[i] = NULL;
    return table;

}
