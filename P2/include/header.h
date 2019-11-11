/*****************************************************************************/
/**   Ejemplo de un posible fichero de cabeceras ("header.h") donde situar  **/
/** las definiciones de constantes, variables y estructuras para MenosC.20  **/
/** Los alumos deberan adaptarlo al desarrollo de su propio compilador.     **/ 
/*****************************************************************************/
#ifndef _HEADER_H
#define _HEADER_H

/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
#define TALLA_TIPO_SIMPLE 1
/************************************* Variables externas definidas en el AL */
extern int yylex();
extern int yyparse();

extern FILE *yyin;                           /* Fichero de entrada           */
extern int   yylineno;                       /* Contador del numero de linea */
extern char *yytext;                         /* Patron detectado             */
extern int yydebug;
/********* Funciones y variables externas definidas en el Programa Principal */
extern void yyerror(const char * msg) ;   /* Tratamiento de errores          */

extern int verbosidad;                   /* Flag si se desea una traza       */
extern int numErrores;              /* Contador del numero de errores        */
extern int dvar;

/*****************************************************************************/

/*
 * Literales nombres tipos
 * por ahora definidos en main.c
 */
extern const char *expTypeNameStr[];
/*
 * Obten nombre del tipo apartir de la constante
 * (para mensages de debug y error)
 */
#define getExpTypeName( typeConst ) ( expTypeNameStr[typeConst] )
/*
 * t_exp
 * atributos de una expresion
*/
typedef struct t_exp
{
    int valor;
    int tipo;
}t_exp;

#endif  /* _HEADER_H */
/*****************************************************************************/

