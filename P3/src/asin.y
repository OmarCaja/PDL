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
#include "libtds.h"
#include "header.h"

%}

%token MAS_ MENOS_ POR_ DIV_ MOD_
%token OPAR_ CPAR_ OBRA_ CBRA_ OCUR_ CCUR_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token AND_ OR_ IGUAL_ DIFERENTE_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ NEG_
%token ENTERO_ BOOLEAN_ ESTRUCTURA_ LEER_ IMPRIMIR_ SI_ MIENTRAS_ SINO_ VERDADERO_ FALSO_
%token INSTREND_ SEP_ INC_ DEC_ <nombre> ID_ <codigo> CTE_

%type <codigo> tipoSimple
%type <tmp_var> expresion expresionLogica expresionIgualdad expresionRelacional
%type <tmp_var> expresionAditiva expresionMultiplicativa
%type <tmp_var> expresionUnaria expresionSufija
%type <tmp_var> constante
%type <codigo> operadorUnario;
%type <listaCampos> listaCampos;
%type <codigo> operadorAsignacion;


%union {
    t_tmp_var tmp_var; // Preparado con la posicion para la generacion de CI
    int codigo;
    char *nombre;
    t_listaCampos listaCampos;
}

%%

programa    : OCUR_ secuenciaSentencias CCUR_ { emite(FIN, crArgNul(), crArgNul(), crArgNul()); }
            ;   

secuenciaSentencias : sentencia
                    | secuenciaSentencias sentencia
                    ;

sentencia   : declaracion
            | instruccion
            ;  

declaracion : tipoSimple ID_ INSTREND_
                {
                    if (!insTdS($2, $1, dvar, REF_TIPO_SIMPLE)) 
                    {
                        yyerror ("Identificador repetido");
                    }
                    else
                    {
                        actualizarDesplazamiento(TALLA_TIPO_SIMPLE);                    
                    }
                }
            | tipoSimple ID_ ASIG_ constante INSTREND_
                {
                    if (!insTdS($2, $1, dvar, REF_TIPO_SIMPLE)) 
                    {
                        yyerror ("Identificador repetido");
                        break;
                    }
                    else 
                    { 
                        actualizarDesplazamiento(TALLA_TIPO_SIMPLE);
                    }

                    if($1 != $4.tipo)
                    {
                        yyerror("Error de tipos en la \"asignacion\"");
                    } 
                }
            | tipoSimple ID_ OBRA_ CTE_ CBRA_ INSTREND_
                {
                    int talla_array = $4;

                    if ($4 <= 0) {
                        yyerror("Talla inapropiada del array");
                        talla_array = 0;
                    }

                    int referencia = insTdA($1, talla_array);

                    if (!insTdS($2, T_ARRAY, dvar, referencia)) 
                    {
                        yyerror ("Identificador repetido");
                    }
                    else 
                    {
                        actualizarDesplazamiento(talla_array * TALLA_TIPO_SIMPLE);
                    }
                }
            | ESTRUCTURA_ OCUR_ listaCampos CCUR_ ID_ INSTREND_
            {
                if(!insTdS($5, T_RECORD, dvar, $3.referencia_struct))
                {
                    yyerror ("Identificador repetido");
                }
                else
                {
                    actualizarDesplazamiento($3.desplazamiento_campo);
                }
            }
            ;

tipoSimple  : ENTERO_ { $$ = T_ENTERO; }
            | BOOLEAN_ { $$ = T_LOGICO; }
            ; 

listaCampos : tipoSimple ID_ INSTREND_
            {
                int desplazamiento = 0;
                $$.referencia_struct = insTdR(NUEVA_ESTRUCTURA, $2 , $1, desplazamiento);
                $$.desplazamiento_campo = desplazamiento + TALLA_TIPO_SIMPLE;
            }
            | listaCampos tipoSimple ID_ INSTREND_
            {
                int referencia;
                int desplazamiento = $1.desplazamiento_campo;
                referencia = insTdR($1.referencia_struct, $3 , $2, desplazamiento);

                $$.referencia_struct = $1.referencia_struct;
                
                if(referencia == TDR_ERROR_CAMPO_EXISTENTE)
                { 
                    yyerror ("Campo repetido"); 
                    $$.desplazamiento_campo = desplazamiento;
                }
                else
                { 
                    $$.desplazamiento_campo = desplazamiento + TALLA_TIPO_SIMPLE;
                }
            }
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
                                    break;
                                }
                                if(simb.tipo != T_ENTERO)
                                {
                                    yyerror("El argumento del \"read\" debe ser \"entero\"");
                                }

                            }
                            | IMPRIMIR_ OPAR_ expresion CPAR_ INSTREND_
                            {
                                if($3.tipo != T_ENTERO && $3.tipo != T_ERROR)
                                {
                                    yyerror("El argumento del \"print\" debe ser \"entero\"");
                                }
                            }
                            ;

instruccionSeleccion    : SI_ OPAR_ expresion CPAR_ 
                        {
                            if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO)
                            {
                                yyerror("La expresion de if debe ser logica");
                            }
                        }
                        instruccion SINO_ instruccion
                        ;

instruccionIteracion    : MIENTRAS_ OPAR_ expresion CPAR_
                        {
                            if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO)
                            {
                                yyerror("La expresion de while debe ser logica");
                            }
                        }
                        instruccion
                        ;

instruccionExpresion    : expresion INSTREND_ {}
                        | INSTREND_
                        ;                    

expresion   : expresionLogica
            | ID_ operadorAsignacion expresion
                {
                    if ($3.tipo == T_ERROR)
                    {
                        $$.tipo = T_ERROR;
                        break;
                    }

                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR; 
                        break;
                    }

                    if (simb.tipo != $3.tipo)
                    {
                        yyerror("Error de tipos en la \"asignacion\"");
                        $$.tipo = T_ERROR;
                        break;
                    }
                    emitirAsignacion(buscaPos($1), $2, $3.pos);
                }
            | ID_ OBRA_ expresion CBRA_ operadorAsignacion expresion
                {
                    if ($3.tipo == T_ERROR || $6.tipo == T_ERROR)
                    {
                        $$.tipo = T_ERROR;
                        break;
                    }

                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR;
                        break;
                    } 
                    
                    if (simb.tipo != T_ARRAY)
                    {
                        yyerror("El identificador debe ser de tipo \"array\"");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    DIM dim = obtTdA(simb.ref);

                    if($3.tipo != T_ENTERO)
                    {
                        yyerror("El indice del \"array\" debe ser entero");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    if (dim.telem != $6.tipo)
                    {
                        yyerror("Error de tipos en la \"asignacion\"");
                        $$.tipo = T_ERROR;
                        break;
                    }

                }
            | ID_ SEP_ ID_ operadorAsignacion expresion
                {
                    if ($5.tipo == T_ERROR)
                    {
                        $$.tipo = T_ERROR;
                        break;
                    }

                    SIMB simb = obtTdS($1);
                    $$.tipo = simb.tipo;
                    if (simb.tipo == T_ERROR){
                        yyerror("Variable no declarada");
                        break;
                    } 

                    if (simb.tipo != T_RECORD)
                    {
                        yyerror("El identificador debe ser \"struct\"");
                        $$.tipo = T_ERROR;
                        break;
                    }   

                    $$.tipo =  obtTdR(simb.ref,$3).tipo;
                    if ($$.tipo == T_ERROR){
                        yyerror("Campo no declarado");
                        break;
                    }

                    if ($$.tipo != $5.tipo)
                    {
                        yyerror("Error de tipos en la \"asignacion\"");
                        $$.tipo = T_ERROR;
                        break;
                    }                  
                }
            ;  

expresionLogica : expresionIgualdad
                | expresionLogica operadorLogico expresionIgualdad
                {
                    if (($1.tipo == T_ERROR || $3.tipo == T_ERROR))
                    {
                        $$.tipo = T_ERROR;
                        break;
                    }
                    if ($1.tipo == $3.tipo && $1.tipo == T_LOGICO)
                    {
                        $$.tipo = $1.tipo;
                    }
                    else
                    {
                        yyerror("Error de tipos en \"expresion logica\"");
                        $$.tipo = T_ERROR;
                    }
                 }
                ;

expresionIgualdad : expresionRelacional
                  | expresionIgualdad operadorIgualdad expresionRelacional
                  {
                    $$.tipo = T_LOGICO;
                    if ($1.tipo == T_ERROR || $3.tipo == T_ERROR)
                    {
                        $$.tipo = T_ERROR;
                    }
                    /**/
                    if ($1.tipo != $3.tipo)
                    {
                        yyerror("Error de tipos en \"expresion de igualdad\"");
                        $$.tipo = T_ERROR;
                    }
                    /**/
                   }
                  ;  

expresionRelacional : expresionAditiva
                    | expresionRelacional operadorRelacional expresionAditiva
                  {
                    $$.tipo = T_LOGICO;
                    if ($1.tipo == T_ERROR || $3.tipo == T_ERROR)
                    {
                        $$.tipo = T_ERROR;
                    }
                    /**/
                    if ($1.tipo != $3.tipo)
                    {
                        yyerror("Error de tipos en \"expresion relacional\"");
                        $$.tipo = T_ERROR;
                    }
                    /**/
                 }
                    ;

expresionAditiva : expresionMultiplicativa 
                 | expresionAditiva operadorAditivo expresionMultiplicativa
                 {
                    $$.tipo = $1.tipo;
                    if($1.tipo == T_ERROR)
                    { break; }
                    
                    if ($1.tipo == $3.tipo && $1.tipo == T_ENTERO)
                    {
                        $$.tipo = $1.tipo;
                    }
                    else
                    {
                        yyerror("Error de tipos en \"expresion aditiva\"");
                        $$.tipo = T_ERROR;
                    }
                 }
                 ;

expresionMultiplicativa : expresionUnaria
                        | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                        {
                            if ($1.tipo == $3.tipo && $1.tipo == T_ENTERO)
                            {
                               $$.tipo = $1.tipo;
                            }
                            else
                            {
                                yyerror("Error de tipos en \"expresion multiplicativa\"");
                                $$.tipo = T_ERROR;
                            }
                        }
                        ;

expresionUnaria : expresionSufija
                | operadorUnario expresionUnaria 
                { 
                    if (($2.tipo == T_ENTERO && $1 != 0) || ($2.tipo == T_LOGICO && $1 == 0))
                    {
                        $$.tipo = $2.tipo;
                    }
                    else
                    {
                        yyerror("Error de tipos en \"expresion unaria\"");
                        $$.tipo = T_ERROR;
                    }
                }
                | operadorIncremento ID_
                {
                    SIMB simb = obtTdS($2);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    if (simb.tipo != T_ENTERO)
                    {
                        yyerror("El identificador debe ser entero");
                        $$.tipo = T_ERROR;
                        break;
                    }
                }
                ;

expresionSufija : OPAR_ expresion CPAR_ { $$ = $2; }
                | ID_ operadorIncremento
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    if (simb.tipo != T_ENTERO)
                    {
                        yyerror("El identificador debe ser entero");
                        $$.tipo = T_ERROR;
                        break;
                    }
                }

                | ID_ OBRA_ expresion CBRA_ 
                { 
                    if ($3.tipo == T_ERROR)
                    {
                        $$.tipo = T_ERROR;
                        break;
                    }

                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    DIM dim = obtTdA(simb.ref);
                    if($3.tipo != T_ENTERO)
                    {
                        yyerror("El indice del \"array\" debe ser entero");
                        $$.tipo = T_ERROR;
                        break;
                    }
                    $$.tipo = dim.telem;

                }
                | ID_
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    if(simb.tipo != T_ENTERO && simb.tipo != T_LOGICO)
                    {
                        yyerror("El identificador debe ser de tipo simple");
                        $$.tipo = T_ERROR;
                        break;
                    }

                    $$.tipo = simb.tipo;
                }
                | ID_ SEP_ ID_
                {
                    SIMB simb = obtTdS($1);
                    $$.tipo = simb.tipo;
                    if (simb.tipo == T_ERROR){
                        yyerror("Variable no declarada");
                        break;
                    }

                    if (simb.tipo != T_RECORD)
                    {
                        yyerror("El identificador debe ser \"struct\"");
                        $$.tipo = T_ERROR;
                        break;
                    }    

                    $$.tipo =  obtTdR(simb.ref,$3).tipo;
                    if ($$.tipo == T_ERROR){
                        yyerror("Campo no declarado");
                        break;
                    } 

                }
                | constante
                ;

constante : CTE_
            {
                $$.tipo = T_ENTERO;
            }
          | VERDADERO_ 
            {
                $$.tipo = T_LOGICO;
            }
          | FALSO_ 
            {
                $$.tipo = T_LOGICO;
            }
            ;  


operadorAsignacion  : ASIG_ { $$ = 0; }
                    | MASASIG_ { $$ = 1; }
                    | MENOSASIG_ { $$ = 2; }
                    | PORASIG_ { $$ = 3; }
                    | DIVASIG_ { $$ = 4; }
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

operadorUnario     : MAS_ { $$ = 1; }
                   | MENOS_ { $$ = 2; }
                   | NEG_ { $$ = 0; }
                   ;  

operadorIncremento : INC_
                   | DEC_
                   ;
%%


void actualizarDesplazamiento(int talla)
{
    dvar += talla;
}

int buscaPos(char* id)
{
    obtTdS(id).desp;
}

void emitirAsignacion(int idPos, int asigCode, int expPos)
{
    if (asigCode == 0)
    {
        emite(EASIG, crAgrPos(idPos), )
    }
    else
    {

    }
}