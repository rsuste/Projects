//
// Created by Radim Šustek on 18-Apr-18.
// hash_table_clear.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
#include <stdlib.h>
#include <stdio.h>
#include "HS_TABLE.h"

void htab_clear(htab_t *t)
{
    unsigned int velikost = t->array_size; // ulozime si velikost pole
    for(unsigned int i = 0;i< velikost;i++) // projdeme vsechny prvky
    {
        if (t->list[i] != NULL) // v pripade ze najdeme prvek na kterem neco je
        {
            ITEM * tmp = t->list[i]; // ulozime si ho
            ITEM * tmp1 = NULL; // a vytvorime pomocny ktery nastavime na NULL
            while (42) //budeme dany index prochazet dokud v tmp->next nebude NULL (dokud nedojdem na konce seznamu)
            {
                if (tmp->next == NULL) // v pripade ze je tmp->next je NULL
                {
                    free(tmp->key); // uvolnim pamet key
                    free(tmp); // uvolnim celou polozku a prerusim cyklus
                    break;
                }
                else // vpripade ze neni
                {
                    tmp1 = tmp; // tak si ulozim aktualni polozku do pomocne tmp1
                    tmp = tmp->next; // do tmp dam dalsi
                    free(tmp1->key); // a uvolnim tu pomocnou
                    free(tmp1);
                }
            }
           // free(t->list[i]);
            t->list[i] = NULL; //po vynulovani index nastavim na NULL
        }

    }


}

