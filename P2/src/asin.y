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
    int tipo;
    char* nombre;
}

%token MAS_ MENOS_ POR_ DIV_ MOD_
%token OPAR_ CPAR_ OBRA_ CBRA_ OCUR_ CCUR_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token AND_ OR_ IGUAL_ DIFERENTE_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ NEG_
%token ENTERO_ BOOLEAN_ ESTRUCTURA_ LEER_ IMPRIMIR_ SI_ MIENTRAS_ SINO_ VERDADERO_ FALSO_
%token INSTREND_ SEP_ INC_ DEC_ <nombre> ID_ <attrCte> CTE_

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
%type <cte> operadorAditivo
%type <cte> operadorRelacional
%type <cte> operadorIgualdad
%type <cte> operadorLogico

%type <tipo> tipoSimple

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
                        if (!insTdS($2, T_ENTERO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }

                    if ($1 == T_LOGICO) {
                        if (!insTdS($2, T_LOGICO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }
                }
            | tipoSimple ID_ ASIG_ constante INSTREND_
                {
                    if ($1 == T_ENTERO) {
                        if (!insTdS($2, T_ENTERO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }

                    if ($1 == T_LOGICO) {
                        if (!insTdS($2, T_LOGICO, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else dvar += TALLA_TIPO_SIMPLE;
                    }
                }
            | tipoSimple ID_ OBRA_ CTE_ CBRA_ INSTREND_
                {
                    int numelem = $4.valor;
                    if ($4.valor <= 0) {
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

tipoSimple  : ENTERO_ { $$ = T_ENTERO; }
            | BOOLEAN_ { $$ = T_LOGICO; }
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

instruccionExpresion    : expresion INSTREND_ {}
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

                    simb = obtTdS($3);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }
                }
            ;  

expresionLogica : expresionIgualdad
                | expresionLogica operadorLogico expresionIgualdad
                {
                    if ($1.tipo == $3.tipo && $1.tipo == T_LOGICO)
                    {
                        $$.tipo = $1.tipo;
                        switch ($2)
                        {
                            case 0:
                                $$.valor = $1.valor && $3.valor;

                            case 1:
                                $$.valor = $1.valor || $3.valor;
                        }
                    }
                    else
                    {
                        yyerror("No se puede realizar la operacion con tipos distintos");
                    }
                 }
                ;

expresionIgualdad : expresionRelacional
                  | expresionIgualdad operadorIgualdad expresionRelacional
                  {
                    if ($1.tipo == $3.tipo && ($1.tipo == T_ENTERO || $1.tipo == T_LOGICO))
                    {
                        $$.tipo = T_LOGICO;
                        switch ($2)
                        {
                            case 0:
                                $$.valor = $1.valor == $3.valor;

                            case 1:
                                $$.valor = $1.valor != $3.valor;
                        }
                    }
                    else
                    {
                        yyerror("No se puede realizar la operacion con tipos distintos");
                    }
                 }
                  ;  

expresionRelacional : expresionAditiva
                    | expresionRelacional operadorRelacional expresionAditiva
                    {
                    if ($1.tipo == $3.tipo && $1.tipo == T_ENTERO)
                    {
                        $$.tipo = T_LOGICO;
                        switch ($2)
                        {
                            case 0:
                                $$.valor = $1.valor > $3.valor;

                            case 1:
                                $$.valor = $1.valor < $3.valor;

                            case 2:
                                $$.valor = $1.valor >= $3.valor;
                            
                            case 3:
                                $$.valor = $1.valor <= $3.valor;
                        }
                    }
                    else
                    {
                        yyerror("No se puede realizar la operacion con tipos distintos");
                    }
                 }
                    ;

expresionAditiva : expresionMultiplicativa 
                 | expresionAditiva operadorAditivo expresionMultiplicativa
                 {
                    if ($1.tipo == $3.tipo && $1.tipo == T_ENTERO)
                    {
                        $$.tipo = $1.tipo;
                        switch ($2)
                        {
                            case 0:
                                $$.valor = $1.valor + $3.valor;

                            case 1:
                                $$.valor = $1.valor - $3.valor;
                        }
                    }
                    else
                    {
                        yyerror("No se puede realizar la operacion con tipos distintos");
                    }
                 }
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
                                        $$.valor = $1.valor % $3.valor; //divisiones por 0 ??, solo puede haber tipos enteros luego no tiene sentido la restriccion del documento
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
                | operadorIncremento ID_
                {
                    SIMB simb = obtTdS($2);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }
                }
                ;

expresionSufija : OPAR_ expresion CPAR_ { $$ = $2; }
                | ID_ operadorIncremento
                {
                        SIMB simb = obtTdS($1);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                | ID_ OBRA_ expresion CBRA_ 
                { 
                    $$ = $3;
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

                        simb = obtTdS($3);
                        if (simb.tipo == T_ERROR) {
                            yyerror("Variable no declarada");
                        }
                    }
                | constante
                ;

constante : CTE_
          | VERDADERO_ 
          {
              $$.tipo = T_LOGICO;
              $$.valor = 1;
          }
          | FALSO_ 
          {
              $$.tipo = T_LOGICO;
              $$.valor = 0;
          }
          ;  


operadorAsignacion  : ASIG_
                    | MASASIG_
                    | MENOSASIG_
                    | PORASIG_
                    | DIVASIG_
                    ; 

operadorLogico : AND_ { $$ = 0; }
               | OR_ { $$ = 1; }
               ; 

operadorIgualdad : IGUAL_ { $$ = 0; }
                 | DIFERENTE_ { $$ = 1; }
                 ;   

operadorRelacional : MAYOR_ { $$ = 0; }
                   | MENOR_ { $$ = 1; }
                   | MAYORIGUAL_ { $$ = 2; }
                   | MENORIGUAL_ { $$ = 3; }
                   ; 

operadorAditivo : MAS_ { $$ = 0; }
                | MENOS_ { $$ = 1; }
                ;

operadorMultiplicativo : POR_ { $$ = 0; }
                       | DIV_ { $$ = 1; }
                       | MOD_ { $$ = 2; }
                       ;  

operadorUnario     : MAS_ { $$ = 1; }
                   | MENOS_ { $$ = -1; }
                   | NEG_ { $$ = 0; }
                   ;  

operadorIncremento : INC_
                   | DEC_
                   ;
%%