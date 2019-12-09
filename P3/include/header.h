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
#define REF_TIPO_SIMPLE -1
#define NUEVA_ESTRUCTURA -1
#define TDR_ERROR_CAMPO_EXISTENTE -1
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

typedef struct
{
    int tipo;
    int posicion;
    int valor;
}t_tmp_var;

typedef struct
{
    int referencia_struct;
    int desplazamiento_campo;
}t_listaCampos;

/* 
typedef struct
{
    int falso;
    int fin;
}t_ins_sel;

typedef struct
{
    int ini;
    int fin;
}t_ins_iter
*/
void actualizarDesplazamiento(int talla);
#endif  /* _HEADER_H */
/*****************************************************************************/

