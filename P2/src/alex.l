/*****************************************************************************/
/*              Especificacion Analizador lexico MenosC.20                   */
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"

#define retornar(x) {if (verbosidad) ECHO; return(x); }
%}
/* ----------------------------------------------------------------------------- */
/*  Estas opciones evitan "warnings" innecesarios y permiten obtener el          */
/*  numero de linea actual en la variable global "yylineno".                     */
/* ----------------------------------------------------------------------------- */
%option noinput       
%option nounput       
%option yylineno  

delimitador    [ \t\n]+
digito         [0-9]
entero         {digito}+
real           {digito}*\.{digito}+|{digito}+\.{digito}*       
numero         {entero}|{real}
comentario     \/\/.*\n
identificador  [a-zA-Z][a-zA-Z0-9_]*

%%
"+"	                       { retornar (MAS_); }
"-"                        { retornar (MENOS_); }
"*"                        { retornar (POR_); }
"/"                        { retornar (DIV_); }
"%"                        { retornar (MOD_); }
"("                        { retornar (OPAR_); }
")"                        { retornar (CPAR_); }
"["                        { retornar (OBRA_); }
"]"                        { retornar (CBRA_); }
"{"                        { retornar (OCUR_); }
"}"                        { retornar (CCUR_); }
"="                        { retornar (ASIG_); }
";"                        { retornar (INSTREND_); }
"."                        { retornar (SEP_); }
"+="                       { retornar (MASASIG_); }
"-="                       { retornar (MENOSASIG_); }
"*="                       { retornar (PORASIG_); }
"/="                       { retornar (DIVASIG_); }
"&&"                       { retornar (AND_); }
"||"                       { retornar (OR_); }
"=="                       { retornar (IGUAL_); }
"!="                       { retornar (DIFERENTE_); }
">"                        { retornar (MAYOR_); } 
"<"                        { retornar (MENOR_); }
">="                       { retornar (MAYORIGUAL_); }
"<="                       { retornar (MENORIGUAL_); }
"!"                        { retornar (NEG_); }
"++"                       { retornar (INC_); }
"--"                       { retornar (DEC_); }
"int"                      { retornar (ENTERO_); }
"bool"                     { retornar (BOOLEAN_); }
"struct"                   { retornar (ESTRUCTURA_); }
"read"                     { retornar (LEER_); }
"print"                    { retornar (IMPRIMIR_); }
"if"                       { retornar (SI_); }
"else"                     { retornar (SINO_); }
"while"                    { retornar (MIENTRAS_); }
"true"                     { retornar (VERDADERO_); }
"false"                    { retornar (FALSO_); }
{delimitador}              { if (verbosidad) ECHO; }
{identificador}            { yylval.nombre = yytext; retornar (ID_); }
{numero}                   { retornar (CTE_); }
{comentario}               { if (verbosidad) ECHO; }
.	                       { yyerror("Caracter desconocido"); }

%%