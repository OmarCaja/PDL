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
#include "libgci.h"

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
%type <codigo> operadorUnario operadorIncremento operadorAsignacion;
%type <codigo> operadorAditivo operadorMultiplicativo;
%type <listaCampos> listaCampos;


%union {
    t_tmp_var tmp_var; // Preparado con la posicion para la generacion de CI
    int codigo;
    int etiqueta;
    char *nombre;
    t_listaCampos listaCampos;
}

%%

programa    : OCUR_ secuenciaSentencias CCUR_ { emite(FIN, crArgNul(), crArgNul(), crArgNul()); volcarCodigo("foobar");}
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
                        yyerror("Identificador repetido");
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
                    else
                    {
                        SIMB _simb = obtTdS($2);
                        emite (EASIG, crArgEnt($4.valor) , crArgNul(), crArgPos(_simb.desp));
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
                                emite(EREAD,crArgNul(),crArgNul(),crArgPos(simb.desp));
                            }
                            | IMPRIMIR_ OPAR_ expresion CPAR_ INSTREND_
                            {
                                if($3.tipo != T_ENTERO && $3.tipo != T_ERROR)
                                {
                                    yyerror("El argumento del \"print\" debe ser \"entero\"");
                                }
                                emite(EWRITE,crArgNul(),crArgNul(),crArgPos($3.posicion));
                            }
                            ;

instruccionSeleccion    : SI_ OPAR_ expresion CPAR_ 
                        {
                            if ($3.tipo != T_ERROR && $3.tipo != T_LOGICO)
                            {
                                yyerror("La expresion de if debe ser logica");
                            }

                            $<etiqueta>$ = creaLans(si);
                            emite(EIGUAL,crArgPos($3.posicion),crArgEnt (0),crArgNul());
                        }
                        instruccion
                        {
                            $<etiqueta>$= creaLans(si);
                            emite(GOTOS,crArgNul(),crArgNul(),crArgNul());
                            completaLans($<etiqueta>5,crArgEtq(si));

                        }
                        
                         SINO_ instruccion
                         {
                            completaLans($<etiqueta>7,crArgEtq(si));
                         }
                        ;

instruccionIteracion    : MIENTRAS_
                        {
                            $<etiqueta>$ = si;
                        }
                        
                         OPAR_ expresion CPAR_
                        {
                            if ($4.tipo != T_ERROR && $4.tipo != T_LOGICO)
                            {
                                yyerror("La expresion de while debe ser logica");
                            }
                            $<etiqueta>$ = creaLans(si);
                            emite(EIGUAL,crArgPos($4.posicion),crArgEnt(0),crArgNul());
                        }
                        instruccion
                        {
                            emite(GOTOS,crArgNul(),crArgNul(),crArgEtq($<etiqueta>2));
                            completaLans($<etiqueta>6,crArgEtq(si));
                        }
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

                    emiteAsignacionConExpresion(crArgPos(buscaPos($1)), crArgPos($3.posicion), $2);

                    $$.posicion = buscaPos($1);
                    $$.tipo = T_ENTERO;
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
                    $$.tipo = T_ENTERO;

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
                    $$.tipo = T_ENTERO;
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
                        $$.posicion = emiteOperacionAritmetica(crArgPos($1.posicion), crArgPos($3.posicion), $2);
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
                                $$.posicion = emiteOperacionAritmetica(crArgPos($1.posicion), crArgPos($3.posicion), $2);
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
                    if (($2.tipo == T_ENTERO && $1 != 0))
                    {
                        $$.posicion = emiteOperacionAritmetica(crArgEnt(0), crArgPos($2.posicion), $1);
                        $$.tipo = $2.tipo;
                    }
                    else if (($2.tipo == T_LOGICO && $1 == 0))
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

                    emiteAsignacionConExpresion(crArgPos(buscaPos($2)), crArgEnt(1), $1);
                    $$.posicion = buscaPos($2);
                    $$.tipo = T_ENTERO;
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
                    $$.posicion = creaVarTemp();
                    emite(EASIG, crArgPos(buscaPos($1)), crArgNul(), crArgPos($$.posicion));

                    emiteAsignacionConExpresion(crArgPos(buscaPos($1)), crArgEnt(1), $2);
                    
                    $$.tipo = T_ENTERO;
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
                    $$.posicion = simb.desp;
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
                $$.valor = $1;
                $$.posicion = creaVarTemp();
                emite(EASIG, crArgEnt($1), crArgNul(), crArgPos($$.posicion));
            }
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


operadorAsignacion  : ASIG_ { $$ = EASIG; }
                    | MASASIG_ { $$ = ESUM; }
                    | MENOSASIG_ { $$ = EDIF; }
                    | PORASIG_ { $$ = EMULT; }
                    | DIVASIG_ { $$ = EDIVI; }
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

operadorAditivo : MAS_ { $$ = ESUM; }
                | MENOS_ { $$ = EDIF; }
                ;

operadorMultiplicativo : POR_ { $$ = EMULT; }
                       | DIV_ { $$ = EDIVI; }
                       | MOD_ { $$ = RESTO; }
                       ;  

operadorUnario     : MAS_ { $$ = ESUM; }
                   | MENOS_ { $$ = EDIF; }
                   | NEG_ { $$ = 0; }
                   ;  

operadorIncremento : INC_ { $$ = ESUM; }
                   | DEC_ { $$ = EDIF; }
                   ;

%%


void actualizarDesplazamiento(int talla)
{
    dvar += talla;
}

int buscaPos(char* id)
{
    return obtTdS(id).desp;
}

int emiteOperacionAritmetica(TIPO_ARG argumento1, TIPO_ARG argumento2, int operador)
{
    int tmp_pos = creaVarTemp();
    emite(operador, argumento1, argumento2, crArgPos(tmp_pos));
    return tmp_pos;
}

void emiteAsignacionConExpresion(TIPO_ARG argumento1, TIPO_ARG argumento2, int operador)
{
    int tmp_pos = argumento2.val;
    
    if (operador != EASIG)
    {
        tmp_pos = emiteOperacionAritmetica(argumento1, argumento2, operador);
    }
    
    emite(EASIG, crArgPos(tmp_pos), crArgNul(), argumento1);
}
