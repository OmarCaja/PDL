%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%token MAS_ MASMAS_ MENOS_ MENOSMENOS_ POR_ DIV_ IG_ IGIG_ NIG_ MASIG_ MENOSIG_ PORIG_ DIVIG_
%token PARA_ PARC_ LLAA_ LLAC_
%token ANDAND_ OROR_ MAYQ_ MAYQIGQ_ MENQ_ MENQIGQ_ NOT_
%token PORCEN_ PUNTCOMA_
%token INT_ BOOL_
%token READ_ PRINT_
%token IF_ ELSE_ WHILE_ STRUCT_
%token CTE_ ID_ REAL_

%%

expMat : exp
       ;
exp    : exp MAS_   term
       | exp MENOS_ term
       | term         
       ;
term   : term POR_ fac
       | term DIV_ fac   
       | fac             
       ;
fac    : PARA_ exp PARC_ 
       | CTE_            
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
