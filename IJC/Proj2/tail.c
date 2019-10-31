//
// Created by Radim Šustek on 05-Apr-18.
// tail.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLINE 1024

int main(int argc, char *argv[]) {
    int ch; //nacte znak
    int num_lines = 0; //pocet radku
    char line[1024]; //nacte radek
    int num = 0;
    if (argc == 2) {
        FILE *f = fopen(argv[1], "r");
        if (f == NULL) {
            fprintf(stderr, "Chyba nepovedlo se nacist soubor");
            return 1;
        }
        while(!feof(f))
        {
            ch = fgetc(f);
            if(ch == '\n')
            {
                num_lines++;
            }
        }
        rewind(f);
        if (num_lines <= 10)
            while(fgets(line,MAXLINE,f) != NULL)
            {
                fputs(line,stdout);
            }
        else if (num_lines > 10) {
            num_lines -=10;
            while(fgets(line,MAXLINE,f) != NULL)
            {
		if(num >= num_lines)
                {
                    fputs(line,stdout);
                }
                num++;
            }
        }
    fclose(f);
    }
    else if (argc == 3)
        if ((strcmp(argv[1],"-n")) == 0) {
            int cislo = atoi(argv[2]);
            FILE *f = stdin;
            if (f == NULL) {
                fprintf(stderr, "Chyba nepovedlo se nacist soubor");
                return 1;
            }
            while(!feof(f))
            {
		ch=fgetc(f);
                if(ch == '\n')
                {
                    num_lines++;
                }
            }
            rewind(f);
            if (num_lines <= 10)
                while(fgets(line,MAXLINE,f) != NULL)
                {
                    fputs(line,stdout);
                }
            else if (num_lines > cislo) {
                num_lines -=cislo;
                while(fgets(line,MAXLINE,f) != NULL)
                {	
                    if(num >= num_lines)
                    {
                        fputs(line,stdout);
                    }
                    num++;
                }
            }
        }
    return 0;
}
