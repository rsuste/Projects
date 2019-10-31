//
// Created by Radim Šustek on 18-Apr-18.
// HS_TABLE.h
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <stdint.h>
#include <stdbool.h>

#ifndef IJC_PROJ_2_HS_TABLE_H
#define IJC_PROJ_2_HS_TABLE_H
// struct
typedef struct htab_listitem {
    char *key; //slovo nactene ze souboru
    unsigned int data; // kolikrat bylo nacteno slovo
    struct htab_listitem *next; // provazani s nasledujicim itemem
} ITEM;

typedef struct HS_table
{
    unsigned int size; //pocet itemu v tabulce
    unsigned int array_size; // bucket size of array
    struct htab_listitem *list[]; // list slov
}htab_t;


//size
int htab_size(htab_t *t);
int htab_bucket_count(htab_t *t);

//remove
bool htab_remove(htab_t *t, char *key);

//find
struct htab_listitem * htab_find(htab_t *t, const char *key);
//lookup
struct htab_listitem * htab_lookup_add(htab_t *t, const char *key);
// for each
void htab_foreach(htab_t *t,void (*function)(char *key, unsigned int data));
//init
htab_t *htab_init(unsigned int size);

//index
unsigned int htab_hash_function(const char *str);

//move
htab_t *htab_move(unsigned int newsize,htab_t *t2);

//clear
void htab_clear(htab_t *t);
void htab_free(htab_t *t);

//print
void htab_print(char *key, unsigned int count);


#endif //IJC_PROJ_2_HS_TABLE_H
