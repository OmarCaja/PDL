%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%token MAS_ MASMAS_ MENOS_ MENOSMENOS_ POR_ DIV_ IG_ IGIG_ NIG_ MASIG_ MENOSIG_ PORIG_ DIVIG_ PORCEN_
%token PARA_ PARC_ CORA_ CORC_ LLAA_ LLAC_
%token ANDAND_ OROR_ MAYQ_ MAYQIGQ_ MENQ_ MENQIGQ_ NOT_
%token PUNTCOMA_ PUNTO_
%token INT_ BOOL_
%token READ_ PRINT_
%token IF_ ELSE_ WHILE_ STRUCT_
%token CTE_ ID_ REAL_

%%

programa :	LLAA_ secSent LLAC_
      ;

secSent :	sentencia
        |	secSent sentencia
        ;

sentencia :	declaracion
          |	instruccion
          ;

declaracion :	tipoSimple ID_ PUNTCOMA_
            |	tipoSimple ID_ IG_ constante PUNTCOMA_
            |	tipoSimple ID_ CORA_ CTE_ CORC_ PUNTCOMA_
            |	STRUCT_ LLAA_ listaCampos LLAC_ ID_ PUNTCOMA_
            ;

tipoSimple  :	INT_
            |	BOOL_
            ;

instruccion :	LLAA_ LLAC_
            |	LLAA_ listaInstrucciones LLAC_
            |	instrEntrSal
            |	instrSelect
            |	instrIter
            |	instrExp
            ;

listaInstrucciones  :	listaInstrucciones instruccion
                    | instruccion
                    ;

instrEntrSal  :	READ_ PARA_ ID_ PARC_ PUNTCOMA_
              |	PRINT_ PARA_ expresion PARC_ PUNTCOMA_
              ;

instrSelect :	IF_ PARA_ expresion PARC_ instruccion ELSE_ instruccion
            ;

instrIter :	WHILE_ PARA_ expresion PARC_ instruccion
          ;

instrExp  :	expresion PUNTCOMA_
          |	PUNTCOMA_
          ;

expresion :	exprLogica
          |	ID_ operAsign expresion
          |	ID_ CORA_ expresion CORC_ operAsign expresion
          |	ID_ PUNTO_ ID_ operAsign expresion
          ;

exprLogica  : exprIgual
            | exprLogica operLogico exprIgual

exprIgual :	exprRelac
          |	exprIgual operIgual exprRelac
          ;

exprRelac :	exprAditiva
          |	exprRelac operRelac exprAditiva
          ;

exprAditiva :	exprMultiplic
            |	exprAditiva operAditivo exprMultiplic
            ;

exprMultiplic :	exprUnaria
              |	exprMultiplic operMultiplic exprUnaria
              ;

exprUnaria  :	exprSufija
            |	operUnario exprUnaria
            |	operIncr ID_
            ;

exprSufija  :	PARA_ expresion PARC_
            |	ID_ operIncr
            |	ID_ CORA_ expresion CORC_
            |	ID_
            |	ID_ PUNTO_ ID_
            |	constante
            ;

constante :	CTE_
          |	TRUE_
          |	FALSE_
          ;

operAsign :	IG_
          |	MASIG_
          |	MENOSIG_
          |	PORIG_
          |	DIVIG_
          ;

operLogico  :	ANDAND_
            |	OROR_
            ;

operIgual :	IGIG_
          |	NIG_
          ;

operRelac :	MAYQ_
          |	MENQ_
          |	MAYQIGQ_
          |	MENQIGQ_
          ;

operAditivo :	MAS_
            |	MENOS_
            ;

operMultiplic :	POR_
              |	DIV_
              |	PORCEN_
              ;

operUnario  :	MAS_
            |	MENOS_
            |	NOT_
            ;

operIncr  :	MASMAS_
          |	MENOSMENOS_
          ;

%%

int verbosidad = FALSE;

void yyerror(const char *msg)
{ fprintf(stderr, "\nError en la linea %d: %s\n", yylineno, msg); }

int main(int argc, char **argv) 
{ int i, n=1 ;

  for (i=1; i<argc; ++i)
    if (strcmp(argv[i], "-v")==0) { verbosidad = TRUE; n++; }
  if (argc == n+1)
    if ((yyin = fopen (argv[n], "r")) == NULL) {
      fprintf (stderr, "El fichero '%s' no es valido\n", argv[n]) ;     
      fprintf (stderr, "Uso: cmc [-v] fichero\n");
    } 
    else yyparse();
  else fprintf (stderr, "Uso: cmc [-v] fichero\n");

  return (0);
} 
