%{
#include <stdio.h>
#include <string.h>
#include "header.h"

#define  retornar(x) {if (verbosidad) ECHO;}
%}
/*-----------------------------------------------------------------------------
  Estas opciones evitan "warnings" innecesarios y permiten obtener el
  numero de linea actual en la variable global "yylineno".
-----------------------------------------------------------------------------*/
%option noinput       
%option nounput       
%option yylineno  

delimitador    [ \t\n]+
digito         [0-9]
entero         {digito}+
real           {digito}+"."{digito}+
idSymbol       [a-zA-Z_]
id             [a-zA-Z]{idSymbol}*
comentario     "//".*

%%
{delimitador}  { if (verbosidad) ECHO; }
"+"	           { retornar (MAS_);   }
"++"	         { retornar (MASMAS_);   }
"-"            { retornar (MENOS_); }
"--"           { retornar (MENOSMENOS_); }
"*"            { retornar (POR_);   }
"/"            { retornar (DIV_);   }
"("            { retornar (OPAR_);  }
")"            { retornar (DIV_);   }
"{"            { retornar (LLAA_);   }
"}"            { retornar (LLAC_);   }
"="            { retornar (IG_);   }
"=="           { retornar (IGIG_);   }
"!="           { retornar (NIG_);   }
"+="           { retornar (MASIG_);   }
"-="           { retornar (MENOSIG_);   }
"*="           { retornar (PORIG_);   }
"/="           { retornar (DIVIG_);   }
"&&"           { retornar (ANDAND_);   }
"||"           { retornar (OROR_);   }
">"            { retornar (MAYQ_);   }
">="           { retornar (MAYQIG_);   }
"<"            { retornar (MENQ_);   }
"<="           { retornar (MENQIG_);   }
"%"            { retornar (PORCEN_);   }
"!"            { retornar (NOT_);   }
";"            { retornar (PUNTCOMA_);   }
"int"          { retornar (INT_);   }
"bool"         { retornar (BOOL_);   }
"read"         { retornar (READ_);   }
"print"        { retornar (PRINT_);   }
"if"           { retornar (IF_);   }
"else"         { retornar (ELSE_);   }
"while"        { retornar (WHILE_);   }
"struct"       { retornar (STRUCT_);   }
{entero}       { retornar (CTE_);   }
{id}           { retornar (ID_);   }
{real}         { retornar (REAL_);   }
{comentario}   { if (verbosidad) ECHO; }
.	             { yyerror("Caracter desconocido"); }

%%
/*****************************************************************************/
int verbosidad = FALSE;                  /* Flag si se desea una traza       */

/*****************************************************************************/
void yyerror(const char *msg)
{ fprintf(stderr, "\nError en la linea %d: %s\n", yylineno, msg); }

/*****************************************************************************/
int main(int argc, char **argv) 
{ int i, n=1 ;

  for (i=1; i<argc; ++i)
    if (strcmp(argv[i], "-v")==0) { verbosidad = TRUE; n++; }
  if (argc == n+1)
    if ((yyin = fopen (argv[n], "r")) == NULL) {
      fprintf (stderr, "El fichero '%s' no es valido\n", argv[n]) ;     
      fprintf (stderr, "Uso: cmc [-v] fichero\n");
    } 
    else yylex ();
  else fprintf (stderr, "Uso: cmc [-v] fichero\n");

  return (0);
} 
/*****************************************************************************/
