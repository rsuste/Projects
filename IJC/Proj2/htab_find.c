//
// Created by Radim Šustek on 22-Apr-18.
// hash_find.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "HS_TABLE.h"

struct htab_listitem * htab_find(htab_t *t, const char *key){
    ITEM *found = NULL;
    for (unsigned int i = 0;i<t->array_size;i++)
    {
        if (t->list[i] != NULL) //v pripade ze se na ukazateli neco nachazi
	{
            found = t->list[i]; // nalezeny prvek vlozime do promene found
            while(42) // overime zda se na danem indexu nenachazi vicero polozek
            {
                if (strcmp(found->key,key)==0) // vpripade ze najde dany prvek vrati odkaz na seznam
                    return t->list[i];
                else if (found->next == NULL)
                    break;
                else if (found->next != NULL)
                    found=found->next;
            }
	}
    }
    return NULL;
}

