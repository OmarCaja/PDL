/*****************************************************************************/
/*Menos C Compiler */
/*****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "header.h"
#include "libtds.h"

int verbosidad = FALSE;             /* Flag si se desea una traza            */
int numErrores = 0;                 /* Contador del numero de errores        */

/**
Literales nombres tipos
*/
const char *expTypeNameStr[] =
{
    "undefined", //T_VACIO
    "int", //T_ENTERO
    "bool", //T_LOGICO
    "array", //T_ARRAY
    "struct", //T_RECORD
    "error", //T_ERROR
};
/*****************************************************************************/
/*  Tratamiento de errores.                                                  */
void yyerror(const char * msg)
{
    numErrores++;  fflush(stdout);
    fprintf(stdout, "Error in line %d: %s\n", yylineno, msg);
}
/*****************************************************************************/
void yywrap()
{
    printf("EOF\n");
    exit (0);
}

/*****************************************************************************/
void printUsage(void)
{
    fprintf (stderr, "Usage:\n\tmenoscc [-v] fichero\n");
}

/*****************************************************************************/
/* Gestiona la linea de comandos e invoca al analizador sintactico-semantico.*/
int main (int argc, char **argv) 
{
    /*Check number of args*/
    if( argc < 2){
        printUsage();
        return(0);
    }
    /**********************************/
    /*Args parsing*/
    yydebug = 0;
    int fileArgNum = argc-1;
    /**/
    int i;
    for (i=1; i<argc; i++){
        if(0); /*just for styling*/
        else if (strcmp(argv[i], "-v") == 0)
        { verbosidad = TRUE;}
        else if (strcmp(argv[i], "--verbose") == 0)
        { verbosidad = TRUE;}
        else if (strcmp(argv[i], "-d") == 0)
        { yydebug = 1; }
        else if (strcmp(argv[i], "--debug") == 0)
        { yydebug = 1; }
        else if (strcmp(argv[i], "-f") == 0)
        { fileArgNum = i+1; }
        else if (strcmp(argv[i], "--file") == 0)
        { fileArgNum = i+1; }
    }
    char *filePath = argv[fileArgNum];
    /**********************************/
    /*Run*/
    if ((yyin = fopen (filePath, "rb")) == NULL){
        fprintf (stderr, "[ERROR]\tCan not open file \"%s\"\n", filePath);
        printUsage();
        return(1);
    }
    //
    if (verbosidad == TRUE)
        fprintf(stdout,"%3d.- ", yylineno);
    //
    int rc;
    rc = yyparse ();
    if (numErrores > 0) 
        fprintf(stderr,"\n[ERROR]\tSyntax errors:\t%d\n", numErrores);
    if( numErrores == 0
        && rc == 0)
        fprintf(stderr,"\n[INFO]\t\"%s\" parsed successfully :')\n",filePath);
    if (verbosidad == TRUE)
    {
        verTdS();
    }
    //
    return (0);
}
/*****************************************************************************/
