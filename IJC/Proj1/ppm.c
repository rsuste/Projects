//
// Created by xsuste11 on 12-Mar-18.
// ppm.c
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//
#include <stdio.h>
#include <malloc.h>
#include "error.h"
#include "ppm.h"

int ppm_write(struct ppm *p, const char * filename) {

    FILE *f = fopen(filename, "rb");
    if (f == NULL) {
        warning_msg("nepodarilo se otevrit soubor\n");
        return -1;
    }

    //zapsat header souboru
    fprintf(f, "P6\n%u %u\n255\n", p->xsize, p->ysize);
    unsigned int PICsize = p->ysize * p->xsize * 3;

    if (fwrite(&p->data, sizeof(char),PICsize,f) != PICsize) {
        warning_msg("nepodarilo se nacist do bitmapy\n");
        free(p->data);
        fclose(f);
        return -1;
    }
    fclose(f);
    return 0;

}

struct ppm * ppm_read(const char * filename) {
    char header[] = "P6";
    char pSIX[10];
    const unsigned int Msize = 1000 * 1000 * 3;
    unsigned int width = 0;
    unsigned int height = 0;
    unsigned int maxCOL = 0;


    //otevre file pro binarni nacitani
    FILE *f = fopen(filename, "rb");
    if (f == NULL) {
        warning_msg("nepodarilo se otevrit soubor\n");
        return NULL;
    }
    //ppm p6 header
    //P6 1024 788 255
    //identifier width height color
    fscanf(f, "%s", pSIX);
    printf("%s\n",pSIX);

    //if (strncmp(header, "P6", 10) != 0)
    if (header[0] != 'P' || header[1] != '6'){
        warning_msg("chyba formatu\n");
        fclose(f);
        return NULL;
    }
    //sirka a vyska obrazku
    fscanf(f, "%u\n %u\n", &width, &height);
    //RGB component
    fscanf(f, "%u\n", &maxCOL);

    printf(" sirka %u\n vyska %u\n barva %d\n",width,height,maxCOL);

    if (maxCOL!=255){
        warning_msg("chyba velikosti barvy\n");
        fclose(f);
        return NULL;
    }

    unsigned long PICsize = height * width * 3;
    printf("velikost bitmapy %lu\n",PICsize);

    //overeni zda nepresahne maximalni velikost zadanou v zadani
    if (PICsize>Msize){
        warning_msg("byla nactena prilis velka velikost obrazku\n");
        fclose(f);
        return NULL;
    }

    struct ppm *bitmap = NULL;

   //overeni zda se povedlo alokovat strukturu bitmap typu ppm
    if ((bitmap = (struct ppm *) malloc(sizeof(struct ppm) + PICsize)) == NULL) {
        warning_msg("chyba pri maloc\n");
        fclose(f);
        return NULL;
    }
    //vlozeni vzsky a sirkz ziskane z obrazku do alokovane strukturz
     bitmap->xsize=width;
     bitmap ->ysize=height;

    //size_t fread(struktura,velikost 1 prvku pole,velikost pole, file)

    if (fread(&bitmap->data, sizeof(char),PICsize,f) != PICsize) {
        warning_msg("nepodarilo se nacist do bitmapy\n");
        free(bitmap->data);
        fclose(f);
        return NULL;
    }
    if (ferror(f) != 0) {
        warning_msg("Error pri nacitani souboru\n");
        free(bitmap->data);
        fclose(f);
        return NULL;
    }

    fclose(f);
    return bitmap;


}


