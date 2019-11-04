###############################################################################
# Ejemplo de fichero para realizar correctamente la tarea de compilacion,     #
# carga y edicion de enlaces de las distintas partes del proyecto             #
###############################################################################

# Directorios de trabajo
SRCDIR = src
INCDIR = include
# Opciones de compilacion
COPT = -Wall -g
CLIB = -lfl
OBJS = ./alex.o  ./asin.o ./main.o
YACCFLAGS = --debug --verbose -Wall
#
menoscc:	$(OBJS)
	gcc  $(OBJS)  -I$(INCDIR)  $(COPT)  $(CLIB) -o menoscc
main.o: $(SRCDIR)/main.c
	gcc  -I$(INCDIR) $(COPT) -c $(SRCDIR)/main.c
asin.o:	asin.c
	gcc  -I$(INCDIR) $(COPT) -c asin.c
alex.o:	alex.c asin.c
	gcc  -I$(INCDIR) $(COPT) -c alex.c
asin.c:	$(SRCDIR)/asin.y
	bison $(YACCFLAGS) -oasin.c  -d $(SRCDIR)/asin.y
	mv ./asin.h ./include	
alex.c:	$(SRCDIR)/alex.l 
	flex -oalex.c $(SRCDIR)/alex.l 

clean:
	rm -f ./alex.c ./asin.c ./include/asin.h 
	rm -f ./*.o  ./include/*.?~ ./src/*.?~
###############################################################################
