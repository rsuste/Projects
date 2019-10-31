$CC = gcc
$CFLAGS = -std=gnu99  -Wall -Wextra -pedantic

.all: proj2

proj2: proj2.c
	$(CC) $(CFLAGS) -pthread proj2.c -o proj2

clean:
	rm proj2 proj2.out

zip:
	zip proj2.zip proj2.c Makefile
