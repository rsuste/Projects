# Makefile
# reseni: IJC-PROJ2
# Author: Radim Sustek (xsuste11),FIT
# prelozeno gcc 7.2

CC = gcc
CFLAGS1 =-O2 -std=c99 -pedantic -Wall -Wextra
CPP = g++
CFLAGS2 =-O2 -std=c++11 -pedantic -Wall
LIB_S = init_s.o clear_s.o print_s.o bucsize_s.o find_s.o foreach_s.o free_s.o lookad_s.o move_s.o remove_s.o size_s.o

LIB_D = init_d.o clear_d.o print_d.o bucsize_d.o find_d.o foreach_d.o free_d.o lookad_d.o move_d.o remove_d.o size_d.o


export LD_LIBRARY_PATH=~/libhtable.so

all: tail tail2 wordcount wordcount-dynamic

tail.o: tail.c
	$(CC) $(CFLAGS1) -c tail.c -o tail.o
tail2.o: tail2.cc
	$(CPP) $(CFLAGS2) -c tail2.cc -o tail2.o
tail: tail.o
	$(CC) $(CFLAGS1)  tail.o -o tail
tail2: tail2.o
	$(CPP) $(CFLAGS2) tail2.o -o tail2

wordcount: wordcount.o io.o libhtable.a
	$(CC) $(CFLAGS1) wordcount.o io.o libhtable.a -o wordcount
wordcount-dynamic: wordcount.o io.o libhtable.so
	$(CC) $(CFLAGS1)  -o wordcount-dynamic io.o wordcount.o  libhtable.so

#wo.o: test_wordcount.cc
#	$(CPP) $(CFLAGS2) -c test_wordcount.cc -o wo.o
#wordcount-test: wo.o
#	$(CPP) $(CFLAGS2) wo.o -o wordcount-test
	 

#static library

init_s.o: HS_TABLE.h hash_table_init.c
	$(CC) $(CFLAGS1) -c hash_table_init.c -o init_s.o

clear_s.o: HS_TABLE.h hash_table_clear.c
	$(CC) $(CFLAGS1) -c hash_table_clear.c -o clear_s.o

print_s.o: HS_TABLE.h hash_table_print.c
	$(CC) $(CFLAGS1) -c hash_table_print.c -o print_s.o

bucsize_s.o: HS_TABLE.h htab_bucketsize.c
	$(CC) $(CFLAGS1) -c htab_bucketsize.c -o bucsize_s.o

find_s.o: HS_TABLE.h htab_find.c
	$(CC) $(CFLAGS1) -c htab_find.c -o find_s.o

foreach_s.o: HS_TABLE.h htab_foreach.c
	$(CC) $(CFLAGS1) -c htab_foreach.c -o foreach_s.o

free_s.o: HS_TABLE.h htab_free.c
	$(CC) $(CFLAGS1) -c htab_free.c -o free_s.o

lookad_s.o: HS_TABLE.h htab_find.c htab_lookup_add.c
	$(CC) $(CFLAGS1) -c htab_lookup_add.c -o lookad_s.o

move_s.o: HS_TABLE.h hash_table_init.c htab_move.c
	$(CC) $(CFLAGS1) -c htab_move.c -o move_s.o

remove_s.o: HS_TABLE.h htab_find.c htab_remove.c
	$(CC) $(CFLAGS1) -c htab_remove.c -o remove_s.o

size_s.o: HS_TABLE.h htab_size.c
	$(CC) $(CFLAGS1) -c htab_size.c -o size_s.o

################
libhtable.a: $(LIB_S)
	ar crs libhtable.a $(LIB_S)

#dynamic library

init_d.o: HS_TABLE.h hash_table_init.c
	$(CC) $(CFLAGS1) -fPIC -c hash_table_init.c -o init_d.o

clear_d.o: HS_TABLE.h hash_table_clear.c
	$(CC) $(CFLAGS1) -fPIC  -c hash_table_clear.c -o clear_d.o

print_d.o: HS_TABLE.h hash_table_print.c
	$(CC) $(CFLAGS1) -fPIC  -c hash_table_print.c -o print_d.o

bucsize_d.o: HS_TABLE.h htab_bucketsize.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_bucketsize.c -o bucsize_d.o

find_d.o: HS_TABLE.h htab_find.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_find.c -o find_d.o

foreach_d.o: HS_TABLE.h htab_foreach.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_foreach.c -o foreach_d.o

free_d.o: HS_TABLE.h htab_free.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_free.c -o free_d.o

lookad_d.o: HS_TABLE.h htab_find.c htab_lookup_add.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_lookup_add.c -o lookad_d.o

move_d.o: HS_TABLE.h hash_table_init.c htab_move.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_move.c -o move_d.o

remove_d.o: HS_TABLE.h htab_find.c htab_remove.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_remove.c -o remove_d.o

size_d.o: HS_TABLE.h htab_size.c
	$(CC) $(CFLAGS1) -fPIC  -c htab_size.c -o size_d.o


#########################
libhtable.so: $(LIB_D)
	$(CC) $(CFLAGS1) -shared -o libhtable.so $(LIB_D)

io.o: io.c io.h
	$(CC) $(CFLAGS1) -c io.c -o io.o

wordcount.o: HS_TABLE.h wordcount.c 
	$(CC) $(CFLAGS1) -c wordcount.c -o wordcount.o

clean:
	rm *.o
	rm tail tail2 wordcount wordcount-dynamic libhtable.a libhtable.so
zip:
	zip xsuste11.zip *.c *.cc *.h Makefile


