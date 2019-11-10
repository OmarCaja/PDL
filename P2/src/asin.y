/*****************************************************************************/
/*             Especificacion analizador sintactico MenosC.20                */
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
%}

%token MAS_ MENOS_ POR_ DIV_ MOD_
%token OPAR_ CPAR_ OBRA_ CBRA_ OCUR_ CCUR_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token AND_ OR_ IGUAL_ DIFERENTE_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ NEG_
%token ENTERO_ BOOLEAN_ ESTRUCTURA_ LEER_ IMPRIMIR_ SI_ MIENTRAS_ SINO_ VERDADERO_ FALSO_
%token INSTREND_ SEP_ INC_ DEC_ ID_ CTE_

%%

programa    : OCUR_ secuenciaSentencias CCUR_
            ;   

secuenciaSentencias : sentencia
                    | secuenciaSentencias sentencia
                    ;

sentencia   : declaracion
            | instruccion
            ;  

declaracion : tipoSimple ID_ INSTREND_
                {
                    if ($1 == T_ENTERO) {
                        if (!insTSimpleTDS($2, T_ENTERO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }

                    if ($1 == T_LOGICO) {
                        if (!insTSimpleTDS($2, T_LOGICO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }
                }
            | tipoSimple ID_ ASIG_ constante INSTREND_
                {
                    if ($1 == T_ENTERO) {
                        if (!insTSimpleTDS($2, T_ENTERO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }

                    if ($1 == T_LOGICO) {
                        if (!insTSimpleTDS($2, T_LOGICO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }
                }
            | tipoSimple ID_ OBRA_ CTE_ CBRA_ INSTREND_
                {
                    int numelem = $4;
                    if ($4 <= 0) {
                        yyerror("Talla inapropiada del array");
                        numelem = 0;
                    }
                    int refe = insTdA($1, numelem);
                    if (!insTdS($2, T_ARRAY, dvar, refe)) {
                        yyerror ("Identificador repetido");
                    }
                    else dvar += numelem * TALLA_TIPO_SIMPLE;
                }
            | ESTRUCTURA_ OCUR_ listaCampos CCUR_ ID_ INSTREND_
            ;

tipoSimple  : ENTERO_
            | BOOLEAN_
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

listaInstrucciones  : instruccion
                    | listaInstrucciones instruccion
                    ; 

instruccionEntradaSalida    : LEER_ OPAR_ ID_ CPAR_ INSTREND_
                            {
                                SIMB simb = obtTdS($3);
                                if (simb.tipo == T_ERROR) {
                                    yyerror("Variable no declarada");
                                }
                            }
                            | IMPRIMIR_ OPAR_ expresion CPAR_ INSTREND_
                            ;

instruccionSeleccion    : SI_ OPAR_ expresion CPAR_ instruccion SINO_ instruccion
                        ;

instruccionIteracion    : MIENTRAS_ OPAR_ expresion CPAR_ instruccion
                        ;

instruccionExpresion    : expresion INSTREND_
                        | INSTREND_
                        ;                    

expresion   : expresionLogica
            | ID_ operadorAsignacion expresion
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }
                }
            | ID_ OBRA_ expresion CBRA_ operadorAsignacion expresion
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }
                }
            | ID_ SEP_ ID_ operadorAsignacion expresion
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }

                    SIMB simb = obtTdS($3);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }
                }
            ;  

expresionLogica : expresionIgualdad
                | expresionLogica operadorLogico expresionIgualdad
                ;

expresionIgualdad   : expresionRelacional
                    | expresionIgualdad operadorIgualdad expresionRelacional
                    ;  

expresionRelacional : expresionAditiva
                    | expresionRelacional operadorRelacional expresionAditiva
                    ;

expresionAditiva    : expresionMultiplicativa
                    | expresionAditiva operadorAditivo expresionMultiplicativa
                    ;

expresionMultiplicativa : expresionUnaria
                        | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                        ;

expresionUnaria : expresionSufija
                | operadorUnario expresionUnaria
                | operadorIncremento ID_
                    {
                        SIMB simb = obtTdS($2);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                ;

expresionSufija : OPAR_ expresion CPAR_
                | ID_ operadorIncremento
                    {
                        SIMB simb = obtTdS($1);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                | ID_ OBRA_ expresion CBRA_
                    {
                        SIMB simb = obtTdS($1);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                | ID_
                    {
                        SIMB simb = obtTdS($1);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                | ID_ SEP_ ID_
                    {
                        SIMB simb = obtTdS($1);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }

                        SIMB simb = obtTdS($3);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                | constante
                ;

constante   : CTE_
            | VERDADERO_
            | FALSO_
            ;  

operadorAsignacion  : ASIG_
                    | MASASIG_
                    | MENOSASIG_
                    | PORASIG_
                    | DIVASIG_
                    ; 

operadorLogico  : AND_
                | OR_
                ; 

operadorIgualdad    : IGUAL_
                    | DIFERENTE_
                    ;   

operadorRelacional  : MAYOR_
                    | MENOR_
                    | MAYORIGUAL_
                    | MENORIGUAL_
                    ; 

operadorAditivo : MAS_
                | MENOS_
                ;

operadorMultiplicativo  : POR_
                        | DIV_
                        | MOD_
                        ;  

operadorUnario  : MAS_ 
                | MENOS_
                | NEG_
                ;  

operadorIncremento  : INC_
                    | DEC_
                    ;
%%