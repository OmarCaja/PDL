/*****************************************************************************/
/*             Especificacion analizador sintactico MenosC.20                */
/*****************************************************************************/
/* NOTA
	Todas las reglas marcadas con TODO corresponden al punto 1
	hay que implementar la declaracion de variables para
	poder comprobar el tipo de estas expresiones
*/
   
%{
#include <stdio.h>
#include <string.h>
#include "libtds.h"
#include "header.h"
/** **/
#define MSG_BUFFER_SIZE 1024
char msgBuffer[MSG_BUFFER_SIZE];

%}

%token MAS_ MENOS_ POR_ DIV_ MOD_
%token OPAR_ CPAR_ OBRA_ CBRA_ OCUR_ CCUR_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token AND_ OR_ IGUAL_ DIFERENTE_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ NEG_
%token ENTERO_ BOOLEAN_ ESTRUCTURA_ LEER_ IMPRIMIR_ SI_ MIENTRAS_ SINO_ VERDADERO_ FALSO_
%token INSTREND_ SEP_ INC_ DEC_ ID_ CTE_

%union {
	t_exp exp;
	int type;
	int value;
	char *string;
}

/*
	Campo de la union vamos a utilizar para los no terminales
	y para cada token
*/
%type <value> VERDADERO_ FALSO_ CTE_

%type <exp> expresion expresionLogica expresionIgualdad expresionRelacional
%type <exp> expresionAditiva expresionMultiplicativa
%type <exp> expresionUnaria expresionSufija
%type <exp> constante
%type <string> ID_
%type <exp> tipoSimple
%%

programa : OCUR_ secuenciaSentencias CCUR_
		 ;   

secuenciaSentencias : sentencia
					| secuenciaSentencias sentencia
					;

sentencia : declaracion
		  | instruccion
		  ;  

declaracion : tipoSimple ID_ INSTREND_
			| tipoSimple ID_ ASIG_ constante INSTREND_
				{
					/*Type Check*/
					if( $1.type != $4.type)
					{
						sprintf(msgBuffer,"Can't assign"
										  " ‘%s’ to ‘%s’",
										 getExpTypeName($1.type),
										 getExpTypeName($4.type)
								);
						yyerror(msgBuffer);
					}
				}
			| tipoSimple ID_ OBRA_ CTE_ CBRA_ INSTREND_
			| ESTRUCTURA_ OCUR_ listaCampos CCUR_ ID_ INSTREND_
			;

tipoSimple : ENTERO_
				{ $$.type = T_ENTERO; }
		   | BOOLEAN_
				{ $$.type = T_LOGICO; }
		   ; 

listaCampos : tipoSimple ID_ INSTREND_
			| listaCampos tipoSimple ID_ INSTREND_
			;

instruccion : OCUR_ CCUR_
			| OCUR_ listaInstrucciones CCUR_
			| instruccionEntradaSalida
			| instruccionSeleccion
			| instruccionIteracion
			| instruccionExpresion
			;

listaInstrucciones : instruccion
				   | listaInstrucciones instruccion
				   ; 

instruccionEntradaSalida : LEER_ OPAR_ ID_ CPAR_ INSTREND_
						 | IMPRIMIR_ OPAR_ expresion CPAR_ INSTREND_
						 ;

instruccionSeleccion : SI_ OPAR_ expresion CPAR_ instruccion SINO_ instruccion
					 ;

instruccionIteracion : MIENTRAS_ OPAR_ expresion CPAR_ instruccion
					 ;

instruccionExpresion : expresion INSTREND_
					 | INSTREND_
					 ;                    

expresion : expresionLogica
		  | ID_ operadorAsignacion expresion
			{ /*TODO*/ $$.type = T_VACIO; }
		  | ID_ OBRA_ expresion CBRA_ operadorAsignacion expresion
			{ /*TODO*/ $$.type = T_VACIO; }
		  | ID_ SEP_ ID_ operadorAsignacion expresion
			{ /*TODO*/ $$.type = T_VACIO; }
		  ;  

expresionLogica : expresionIgualdad
				| expresionLogica operadorLogico expresionIgualdad
				;

expresionIgualdad : expresionRelacional
				  | expresionIgualdad operadorIgualdad expresionRelacional
				  ;  

expresionRelacional : expresionAditiva
					| expresionRelacional operadorRelacional expresionAditiva
					;

expresionAditiva : expresionMultiplicativa
				 | expresionAditiva operadorAditivo expresionMultiplicativa
					{
						/*Type Check*/
						if( $1.type != $3.type)
						{
							sprintf(msgBuffer,"invalid operands of types"
											  " ‘%s’ and ‘%s’"
											  "to additive operator",
											 getExpTypeName($1.type),
											 getExpTypeName($3.type)
									);
							yyerror(msgBuffer);
						}
					}
				 ;

expresionMultiplicativa : expresionUnaria
						| expresionMultiplicativa operadorMultiplicativo expresionUnaria
							{
								/*Type Check*/
								if( $1.type != $3.type)
								{
									sprintf(msgBuffer,"invalid operands of types"
													  " ‘%s’ and ‘%s’"
													  "to multiplicative operator",
													 getExpTypeName($1.type),
													 getExpTypeName($3.type)
											);
									yyerror(msgBuffer);
								}
							}
						;

expresionUnaria : expresionSufija
				| operadorUnario expresionUnaria
					{ $$ = $2; }
				| operadorIncremento ID_
					{
						$$.type = T_VACIO;
					}
				;

expresionSufija : OPAR_ expresion CPAR_
					{ $$ = $2; }
				| ID_ operadorIncremento
					{ /*TODO*/ $$.type = T_VACIO; }
				| ID_ OBRA_ expresion CBRA_
					{ /*TODO*/ $$.type = T_VACIO; }
				| ID_
					{ /*TODO*/ $$.type = T_VACIO; }
				| ID_ SEP_ ID_
					{ /*TODO*/ $$.type = T_VACIO; }
				| constante
				;

constante : CTE_
			{ $$.value = $1; $$.type = T_ENTERO; }
		  | VERDADERO_
			{ $$.value = 0; $$.type = T_LOGICO; }
		  | FALSO_
			{ $$.value = 1; $$.type = T_LOGICO; }
		  ;

operadorAsignacion : ASIG_
				   | MASASIG_
				   | MENOSASIG_
				   | PORASIG_
				   | DIVASIG_
				   ; 

operadorLogico : AND_
			   | OR_
			   ; 

operadorIgualdad : IGUAL_
				 | DIFERENTE_
				 ;   

operadorRelacional : MAYOR_
				   | MENOR_
				   | MAYORIGUAL_
				   | MENORIGUAL_
				   ; 

operadorAditivo : MAS_
				| MENOS_
				;

operadorMultiplicativo : POR_
					   | DIV_
					   | MOD_
					   ;  

operadorUnario     : MAS_ 
				   | MENOS_
				   | NEG_
				   ;  

operadorIncremento : INC_
				   | DEC_
				   ;
%%
