//
// Created by Radim Šustek on 22-Apr-18.
// htab_remove.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//


#include <stdbool.h>
#include <stdlib.h>
#include "HS_TABLE.h"

bool htab_remove(htab_t *t, char *key)
{
    if (htab_find(t,key) != NULL) // v pripade ze najdu polozku
    {
        ITEM *tmp = htab_find(t,key); // ulozim index
        if (tmp->next == NULL)// v pripade ze se na indexu nachazi jen jedna polozka
        {
            free(tmp);
            t->size--;
            return true;
        }
        else if (tmp->next != NULL) // v pripade ze se na zadanem indexu nachazi vice nez jedna polozka
        {
            ITEM * previus = tmp;
            tmp = tmp->next;
            if (previus->key == key)
            {
                free(previus);
                t->size--;
                return true;
            }
            else if (tmp->key == key)
            {
                previus->next = tmp->next;
                t->size--;
                free(tmp);
            }
            else {
                previus = tmp;
                tmp=tmp->next;
            }
        }
    }
    else if (htab_find(t,key) == NULL)
        return false;
return false;


}
