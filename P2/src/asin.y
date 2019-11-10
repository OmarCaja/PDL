/*****************************************************************************/
/*             Especificacion analizador sintactico MenosC.20                */
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"
%}

%union
{
    constante attrCte;
    int cte;
}

%token MAS_ MENOS_ POR_ DIV_ MOD_
%token OPAR_ CPAR_ OBRA_ CBRA_ OCUR_ CCUR_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token AND_ OR_ IGUAL_ DIFERENTE_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ NEG_
%token ENTERO_ BOOLEAN_ ESTRUCTURA_ LEER_ IMPRIMIR_ SI_ MIENTRAS_ SINO_ VERDADERO_ FALSO_
%token INSTREND_ SEP_ INC_ DEC_ ID_ <attrCte> CTE_

%type <attrCte> operadorIncremento
%type <attrCte> constante
%type <attrCte> expresionSufija
%type <attrCte> expresionUnaria
%type <attrCte> expresionMultiplicativa
%type <attrCte> expresionAditiva
%type <attrCte> expresionRelacional
%type <attrCte> expresionIgualdad
%type <attrCte> expresionLogica
%type <attrCte> expresion
%type <cte> operadorUnario
%type <cte> operadorMultiplicativo

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
            | tipoSimple ID_ OBRA_ CTE_ CBRA_ INSTREND_
            | ESTRUCTURA_ OCUR_ listaCampos CCUR_ ID_ INSTREND_
            ;

tipoSimple : ENTERO_
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

instruccionExpresion : expresion INSTREND_ {}
                     | INSTREND_
                     ;                    

expresion : expresionLogica
          | ID_ operadorAsignacion expresion { }
          | ID_ OBRA_ expresion CBRA_ operadorAsignacion expresion { }
          | ID_ SEP_ ID_ operadorAsignacion expresion { }
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
                 ;

expresionMultiplicativa : expresionUnaria
                        | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                        {
                            if ($1.tipo == $3.tipo && $1.tipo == T_ENTERO)
                            {
                                $$.tipo = $1.tipo;
                                switch ($2)
                                {
                                    case 0:
                                        $$.valor = $1.valor * $3.valor;

                                    case 1:
                                        $$.valor = $1.valor / $3.valor; //divisiones por 0 ??

                                    case 2:
                                        $$.valor = $1.valor % $3.valor; //divisiones por 0 ??
                                }
                            }
                            else
                            {
                                yyerror("No se puede realizar la operacion con tipos distintos");
                            }
                        }
                        ;

expresionUnaria : expresionSufija
                | operadorUnario expresionUnaria 
                { 
                    $$.tipo = $2.tipo;
                    if ($2.tipo == T_ENTERO && $1 != 0)
                    {
                        $$.valor = $1 * $2.valor;
                    }
                    else if ($2.tipo == T_LOGICO && $1 == 0)
                    {
                        $$.valor = !$2.valor;
                    }
                    else
                    {
                        yyerror("el operador especificado no se puede aplicar a ese tipo");
                    }
                }
                | operadorIncremento ID_ { }
                ;

expresionSufija : OPAR_ expresion CPAR_ { $$ = $2; }
                | ID_ operadorIncremento { }
                | ID_ OBRA_ expresion CBRA_ { $$ = $3; }
                | ID_ { }
                | ID_ SEP_ ID_ { }
                | constante
                ;

constante : CTE_
          | VERDADERO_ { }
          | FALSO_ { }
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

operadorMultiplicativo : POR_ { $$ = 0; }
                       | DIV_ { $$ = 1; }
                       | MOD_ { $$ = 2; }
                       ;  

operadorUnario     : MAS_ { $$ = 1; }
                   | MENOS_ { $$ = -1; }
                   | NEG_ { $$ = 0; }
                   ;  

operadorIncremento : INC_ { $$.tipo = T_ENTERO; $$.valor = 1; }
                   | DEC_ { $$.tipo = T_ENTERO; $$.valor = -1; }
                   ;
%%