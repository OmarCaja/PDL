%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"

#define  retornar(x) {if (verbosidad) ECHO; return(x);}
%}

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
"="            { retornar (IG_);   }
"=="           { retornar (IGIG_);   }
"!="           { retornar (NIG_);   }
"+="           { retornar (MASIG_);   }
"-="           { retornar (MENOSIG_);   }
"*="           { retornar (PORIG_);   }
"/="           { retornar (DIVIG_);   }
"("            { retornar (PARA_);  }
")"            { retornar (PARC_);   }
"["            { retornar (CORA_);   }
"]"            { retornar (CORC_);   }
"{"            { retornar (LLAA_);   }
"}"            { retornar (LLAC_);   }
"&&"           { retornar (ANDAND_);   }
"||"           { retornar (OROR_);   }
">"            { retornar (MAYQ_);   }
">="           { retornar (MAYQIGQ_);   }
"<"            { retornar (MENQ_);   }
"<="           { retornar (MENQIGQ_);   }
"%"            { retornar (PORCEN_);   }
"!"            { retornar (NOT_);   }
";"            { retornar (PUNTCOMA_);   }
"."            { retornar (PUNTO_);   }
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
