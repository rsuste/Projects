//
// Created xsuste11 on 17-Mar-18.
// steg-decode.c
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//

#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <ctype.h>
#include "ppm.h"
#include "bit_array.h"
#include "error.h"
#include "Eratosthenes.h"

#define max_resolution (3*1000*1000)



int main(int argc,char *argv[]){
//overeni nacteni argumentu
    if (argc != 2){
        warning_msg("nebyl zadan ppm soubor\n");
    }

    struct ppm *bitmap;
    bitmap = ppm_read(argv[1]);


    //overeni nacteni
    if (bitmap == NULL){
        warning_msg("nepodarilo se nacist soubor\n");
    }
    else {
        //vytvobreni pole bitu o maximalni mozne velikost obrazku
        bit_array_create(BitM,max_resolution);
        //najit vsechny prvocisla
        Eratosthenes(BitM);

        int character = 0;
	char znak ='\0';
       	int poc = 0;	

	//rozliseni obrazku
        unsigned long resolution = bitmap->xsize*bitmap->ysize*3;
	//prochazeni bitu bitmapy
        for (unsigned long i=11;i<resolution+1;i++)
            if ((bit_array_getbit(BitM, i)) == 0) {
                character = bitmap->data[i] & 1; //ulozi LSB bit
		//dany bit ulozime na pozici v promene
		if (character==  0){
			//zneguje bit(character) na pozici(poc) v poli(znak)
			znak &= ~(character<<(poc % (sizeof(znak)*CHAR_BIT)));
			poc++;
		}
		else{	
			//vlozi bit(character) na pozici(poc) v poli(znak) 
			znak |= (character<<(poc % (sizeof(znak)*CHAR_BIT)));
			poc++;
		}
		if (poc % CHAR_BIT == 0)
		{
		//jeli citelny
                if (isprint(znak)) {
                    fputc(znak, stdout);
                    znak = 0;//nulujeme 
                }
                else if (znak == '\0'){
		    printf("\n");			
                    break;
        		}
		}	
	}
}

    free(bitmap);
    return EXIT_SUCCESS;

    }


