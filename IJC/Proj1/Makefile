 
# Makefile
# Reseni: IJC-PROJ1
# Autor: Radim Sustek (xsuste11),FIT
# prelozeno: gcc 7.2

CC = gcc
CFLAGS = -o2 -std=c99 -Wall -pedantic -g -m32 -Wextra

all: primes steg-decode

primes: error.o eratho.o primes.o	
	$ ulimit -s unlimited
	$(CC) $(CFLAGS) primes.o error.o eratho.o -o primes
	$(CC) $(CFLAGS) -DUSE_INLINE primes.o eratho.o error.o -o primes-i

steg-decode: steg-decode.o eratho.o ppm.o error.o
	$(CC) $(CFLAGS) steg-decode.o eratho.o ppm.o error.o -o steg-decode

error.o: error.h error.c
	$(CC) $(CFLAGS) -c error.c -o error.o

ppm.o: ppm.c ppm.h error.h Eratosthenes.h bit_array.h
	$(CC) $(CFLAGS) -c ppm.c -o ppm.o

eratho.o: Eratosthenes.c Eratosthenes.h bit_array.h error.h
	$(CC) $(CFLAGS) -c Eratosthenes.c -o eratho.o

primes.o: primes.c bit_array.h error.h Eratosthenes.h
	$(CC) $(CFLAGS) -c primes.c -o primes.o

steg-decode.o: steg-decode.c bit_array.h error.h Eratosthenes.h ppm.h
	$(CC) $(CFLAGS) -c steg-decode.c -o steg-decode.o


clean:
	rm *.o primes primes-i steg-decode
run:
	make
	@echo Makro
	@time ./primes
	@echo Inline-funkce
	@time ./primes-i
limit:
	ulimit -s unlimited
help:
	@echo parametry
	@echo help
	@echo run
	@echo limit
	@echo clean


