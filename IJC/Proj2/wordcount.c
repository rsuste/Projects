//
// Created by Radim Šustek on 09-Apr-18.
// wordcount.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

// wordcount-.cc
// Použijte: g++ -std=c++11
// Příklad použití STL kontejneru map<> nebo unordered_map<>
// Program počítá četnost slov ve vstupním textu,
// slovo je cokoli oddělené "bílým znakem" === isspace

#include <stdio.h>
#include <malloc.h>
#include <ctype.h>
#include "HS_TABLE.h"
#include "io.h"

#define LIMIT  10000




int main(){
    htab_t *table =htab_init(LIMIT);
    char word[128] = {0,}; //string word
    while(get_word(word,127,stdin) != 0)
    {
       htab_lookup_add(table,word);
    }
    htab_foreach(table,htab_print);
    htab_free(table);
    return 0;

}
