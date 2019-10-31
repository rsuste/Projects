//
// Created by xsuste11 on 12-Mar-18.
// ppm.h
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//

#ifndef IJC_PROJ_1_PPM_H
#define IJC_PROJ_1_PPM_H

struct ppm {
    unsigned xsize;
    unsigned ysize;
    char data[];
};

struct ppm * ppm_read(const char * filename);

int ppm_write(struct ppm *p, const char * filename);


#endif //IJC_PROJ_1_PPM_H
