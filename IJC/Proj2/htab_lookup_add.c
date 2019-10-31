//
// Created by Radim Šustek on 22-Apr-18.
// htab_loookup_add.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//


#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include "HS_TABLE.h"

struct htab_listitem * htab_lookup_add(htab_t *t, const char *key)
{
    if (t == NULL) //overime platnost odkazu
    {
        fprintf(stderr,"Neplatny odkaz");
        return NULL;
    }
    if (htab_find(t,key) == NULL) // zda nebyl nalezen
    {
        if (t->list[htab_hash_function(key) % t->array_size] == NULL) { // v pripade ze na zadanem indexu este nic neni
            ITEM *new_word = malloc(sizeof(ITEM)); //naalokuji new item
            if (new_word == NULL) // overim zda se alokace povedla
            {
                fprintf(stderr, "Nepovedl se malloc1");
                return NULL;
            }
	    new_word->key = malloc(sizeof(char)*strlen(key)+1);
	    if (new_word->key == NULL)
	    {
	    	fprintf(stderr,"Nepovedl se malloc2");
	 	return NULL;
	    }
            strcpy(new_word->key,key); // ulozim slovo
            new_word->data = 1; // nastavim pocet na 1 jelikoz ukladam novej prvek
            new_word->next = NULL; // ukazatel na dalsi prvek nastavim na NULL
            t->list[htab_hash_function(key) % t->array_size] = new_word;// ulozim nove naalokovane slovo do tabulky
            t->size++;
            return new_word; // vratim odkaz na nove slovo
        }
        else  // v pripade ze bul nalezen a na indexu neco je
        {
            ITEM *f_index = htab_find(t,key);
            while(42) // dojdeme na konec seznamu
            {
                f_index = f_index->next;
                if (f_index->next == NULL)
                    break;
            }
            ITEM *l_index = malloc(sizeof(ITEM)); // alokujeme novou polozku
            if (l_index == NULL) // overim zda se alokace povedla
            {
                fprintf(stderr, "Nepovedl se malloc3");
                return NULL;
            }
	    l_index->key = malloc(sizeof(char)*strlen(key)+1);
	    if (l_index->key == NULL)
		{
		fprintf(stderr,"Nepovedl se malloc4");
		return NULL;
		}
            strcpy(l_index->key,key);
            l_index->data = 1;
            l_index->next = NULL;
            f_index->next=l_index; // ulozime ji nakonec seznamu
            t->size++;
            return l_index;

        }
    }
    else if (htab_find(t,key) != NULL) // zda byl nalezen
    {
        ITEM *found = htab_find(t,key); // ulozim index
        while(42) // dojdeme na konec seznamu
        {
            if (strcmp(found->key,key) == 0) // pokud polozka odpovida tak zvisim u ni pocitadlo a vratim odkaz na ni
            {
                found->data++;
                t->size++;
                return found;
            }
            else
                found=found->next; // kdyz ne tak se posunu na dalsi
            if (found->next == NULL)
                break;
        }

    }

return NULL;
}
