//
// Created by xsuste11 on 12-Mar-18.
// error.c
// Reseni: IJC-PROJ1
// Autor: Radim Sustek (xsuste11),FIT
// prelozeno: gcc 7.2
//
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>



void warning_msg(const char *fmt, ...){

    va_list list;
    va_start(list,fmt);
    fprintf(stderr,"CHYBA: ");
    vfprintf(stderr,fmt,list);
    va_end(list);

}

void error_exit(const char *fmt, ...){

    va_list list;
    va_start(list,fmt);
    fprintf(stderr,"CHYBA: ");
    vfprintf(stderr,fmt,list);
    va_end(list);
    exit(1);

}

