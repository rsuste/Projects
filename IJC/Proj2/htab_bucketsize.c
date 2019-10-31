//
// Created by Radim Šustek on 22-Apr-18.
// htab_bucketsize.c
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include "HS_TABLE.h"

int htab_bucket_count(htab_t *t)
{
    return t->array_size;
}
