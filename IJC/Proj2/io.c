//
// Created by Radim Šustek on 23-Apr-18.
// io.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

int get_word(char *s, int max, FILE *f) {
    int ch; // na ulozeni znaku
    int poc = 0; // na ulozeni pozice
    if (f == NULL) { // v prpade ze je odkaz nenulovy
        fprintf(stderr, "Chyba nepovedlo se nacist soubor");
        return 0;
    }
    while ((ch = fgetc(f)) != EOF && poc < max - 1) { // nactem znak
        if (isspace(ch)) { // zda se nejedna o mezeru	
            break;

        } else { // pokud najedem na mezeru
	    s[poc] = ch;
	    poc++;
        }
    }
    s[poc] = 0;
    return poc; // a vrato kde jsme skoncili
}
