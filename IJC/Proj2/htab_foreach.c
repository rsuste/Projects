//
// Created by Radim Šustek on 22-Apr-18.
// htab_foreach.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <stdint.h>
#include <stdio.h>
#include "HS_TABLE.h"

void htab_foreach(htab_t *t,void (*function)(char *key, unsigned int data))
{

    unsigned int velikost = t->array_size; // ulozime si pocet pointru
    for (unsigned int i = 0;i < velikost;i++) // projdeme vsechny
    {
     if (t->list[i] != NULL) // v pripade ze se na nem neco nachazi
     {
         ITEM *found = t->list[i]; // ulozim si ho do found
         while(42) //prochazim vsechny prvky ktere se na danem indexu nachazi
         {
             function(found->key,found->data);
             if (found->next == NULL)
                 break;
             else
                 found=found->next;

         }
     }
    }

}
