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

/** **/
#define MSG_BUFFER_SIZE 1024
char msgBuffer[MSG_BUFFER_SIZE];
/** una ref == -1 se usa para crear una nueva TDR*/
#define TDR_MAKE_NEW_TABLE (-1)
#define TDR_REDEFINE_ERROR (-1)
/**Referencia que estamos usando en la tabla de registros**/
static int currentTDRRef = TDR_MAKE_NEW_TABLE;
/**Desplazamiento del campo*/
static int currentTDRoffset = 0x00;

%}

%token MAS_ MENOS_ POR_ DIV_ MOD_
%token OPAR_ CPAR_ OBRA_ CBRA_ OCUR_ CCUR_
%token ASIG_ MASASIG_ MENOSASIG_ PORASIG_ DIVASIG_
%token AND_ OR_ IGUAL_ DIFERENTE_ MAYOR_ MENOR_ MAYORIGUAL_ MENORIGUAL_ NEG_
%token ENTERO_ BOOLEAN_ ESTRUCTURA_ LEER_ IMPRIMIR_ SI_ MIENTRAS_ SINO_ VERDADERO_ FALSO_
%token INSTREND_ SEP_ INC_ DEC_ <nombre> ID_ <exp> CTE_

%type <tipo> tipoSimple

%union {
    t_exp exp;
    int tipo;
    int valor;
    char *nombre;
}

/*
    Campo de la union vamos a utilizar para los no terminales
    y para cada token
*/

%type <exp> expresion expresionLogica expresionIgualdad expresionRelacional
%type <exp> expresionAditiva expresionMultiplicativa
%type <exp> expresionUnaria expresionSufija
%type <exp> constante

%type <valor> operadorUnario;
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
                    
                        if (!insTdS($2, $1, dvar, -1)) {
                            yyerror ("Identificador repetido");
                        }
                        else
                        {
                            dvar += TALLA_TIPO_SIMPLE;                    
                        }
                        verTdS();
                }
            | tipoSimple ID_ ASIG_ constante INSTREND_
                {
                    /*type Check*/
                    if($1 != $4.tipo)
                    {
                        sprintf(msgBuffer,
                                "Can't assign"
                                " ‘%s’ to ‘%s’",
                                getExpTypeName($1),
                                getExpTypeName($4.tipo)
                                );
                        yyerror(msgBuffer);
                    } 
                    else 
                    {
                        
                        if (!insTdS($2, $1, dvar, -1)) 
                        {
                            yyerror ("Identificador repetido");
                        } 
                        else 
                        { 
                            dvar += TALLA_TIPO_SIMPLE;
                        }
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
            {
                 int rc;
                 printf("%s\n",$5);
                 rc = insTdS($5, T_RECORD, dvar, currentTDRRef);
                 if(rc == FALSE)
                 {
                     sprintf(msgBuffer,"'%s' Identificador repetido", $5);
                     yyerror (msgBuffer);
                 }
                 else
                 {
                     dvar += currentTDRoffset;
                 }
                 /*
                    Los proximos campos que encontremos
                    son de otra estructura, así que crearemos nueva tabla
                 */
                 currentTDRoffset = 0x00;
                 currentTDRRef = TDR_MAKE_NEW_TABLE;
            }
            ;

tipoSimple  : ENTERO_ { $$ = T_ENTERO; }
            | BOOLEAN_ { $$ = T_LOGICO; }
            ; 

listaCampos : tipoSimple ID_ INSTREND_
            | listaCampos tipoSimple ID_ INSTREND_
            {
                int rc;
                rc = insTdR(currentTDRRef, $3 , $2, currentTDRoffset);
                if(currentTDRRef == TDR_MAKE_NEW_TABLE)
                { /* Guardamos  la referencia a la nueva tabla*/
                    currentTDRRef = rc;
                    currentTDRoffset += TALLA_TIPO_SIMPLE;
                    break;
                }
                /***/
                if(rc == TDR_REDEFINE_ERROR)
                { yyerror ("Identificador repetido"); }
                else
                { currentTDRoffset += TALLA_TIPO_SIMPLE; }
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
                            ;

instruccionSeleccion    : SI_ OPAR_ expresion CPAR_ instruccion SINO_ instruccion
                        {
                            if ($3.tipo != T_LOGICO)
                            {
                                yyerror("La expresion de if debe ser logica");
                            }
                        }
                        ;

instruccionIteracion    : MIENTRAS_ OPAR_ expresion 
                        {
                            if ($3.tipo != T_LOGICO)
                            {
                                yyerror("La expresion de while debe ser logica");
                            }
                        }
                        
                        CPAR_ instruccion
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

                    $$.tipo = simb.tipo;
                }
            | ID_ OBRA_ expresion CBRA_ operadorAsignacion expresion
                {
                    
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    } 
                    
                    //$$.tipo = simb.tipo;  simb.tipo es T_ARRAY
                    
                    DIM dim = obtTdA(simb.ref);
                    if($3.tipo != T_ENTERO && $3.tipo != T_ERROR)
                    {
                        yyerror("El indice del \"array\" debe ser entero");
                    }
                    $$.tipo = dim.telem;


                }
            | ID_ SEP_ ID_ operadorAsignacion expresion
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
                        yyerror("No se puede realizar la operacion con tipos distintos");
                        $$.tipo = T_ERROR;
                    }
                 }
                ;

expresionIgualdad : expresionRelacional
                  | expresionIgualdad operadorIgualdad expresionRelacional
                  {
                    if ($1.tipo == $3.tipo && ($1.tipo == T_ENTERO || $1.tipo == T_LOGICO))
                    {
                        $$.tipo = T_LOGICO;
                    }
                    else
                    {
                        yyerror("No se puede realizar la operacion con tipos distintos");
                        $$.tipo = T_ERROR;
                    }
                    }
                  ;  

expresionRelacional : expresionAditiva
                    | expresionRelacional operadorRelacional expresionAditiva
                    {
                    if ($1.tipo == $3.tipo && $1.tipo == T_ENTERO)
                    {
                        $$.tipo = $1.tipo;
                    }
                    else
                    {
                        yyerror("No se puede realizar la operacion con tipos distintos");
                        $$.tipo = T_ERROR;
                    }
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
                        sprintf(msgBuffer,
                                    "invalid operands of tipos"
                                    " ‘%s’ and ‘%s’"
                                    "to additive operator",
                                    getExpTypeName($1.tipo),
                                    getExpTypeName($3.tipo)
                                    );
                            yyerror(msgBuffer);
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
                                yyerror("No se puede realizar la operacion con tipos distintos");
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
                        yyerror("el operador especificado no se puede aplicar a ese tipo");
                        $$.tipo = T_ERROR;
                    }
                }
                | operadorIncremento ID_
                {
                    SIMB simb = obtTdS($2);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }

                    $$.tipo = simb.tipo;
                }
                ;

expresionSufija : OPAR_ expresion CPAR_ { $$ = $2; }
                | ID_ operadorIncremento
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                    }

                    $$.tipo = simb.tipo;
                }

                | ID_ OBRA_ expresion CBRA_ 
                { 
                    //$$ = $3;
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
                        $$.tipo = T_ERROR;
                    }
                    DIM dim = obtTdA(simb.ref);
                    if($3.tipo != T_ENTERO && $3.tipo != T_ERROR)
                    {
                        yyerror("El indice del \"array\" debe ser entero");
                    }
                    $$.tipo = dim.telem;

                    //$$.tipo = simb.tipo;

                }
                | ID_
                {
                    SIMB simb = obtTdS($1);
                    if (simb.tipo == T_ERROR) {
                        yyerror("Variable no declarada");
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
                    /**/               
                    $$.tipo =  obtTdR(simb.ref,$3).tipo;
                    if ($$.tipo == T_ERROR){
                        yyerror("campo no declarada");
                        break;
                    } 
                    /**/
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

operadorUnario     : MAS_ { $$ = 0; }
                   | MENOS_ { $$ = 1; }
                   | NEG_ { $$ = 2; }
                   ;  

operadorIncremento : INC_
                   | DEC_
                   ;
%%
