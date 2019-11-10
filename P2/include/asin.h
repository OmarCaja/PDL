/* A Bison parser, made by GNU Bison 3.4.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2019 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    MAS_ = 258,
    MENOS_ = 259,
    POR_ = 260,
    DIV_ = 261,
    MOD_ = 262,
    OPAR_ = 263,
    CPAR_ = 264,
    OBRA_ = 265,
    CBRA_ = 266,
    OCUR_ = 267,
    CCUR_ = 268,
    ASIG_ = 269,
    MASASIG_ = 270,
    MENOSASIG_ = 271,
    PORASIG_ = 272,
    DIVASIG_ = 273,
    AND_ = 274,
    OR_ = 275,
    IGUAL_ = 276,
    DIFERENTE_ = 277,
    MAYOR_ = 278,
    MENOR_ = 279,
    MAYORIGUAL_ = 280,
    MENORIGUAL_ = 281,
    NEG_ = 282,
    ENTERO_ = 283,
    BOOLEAN_ = 284,
    ESTRUCTURA_ = 285,
    LEER_ = 286,
    IMPRIMIR_ = 287,
    SI_ = 288,
    MIENTRAS_ = 289,
    SINO_ = 290,
    VERDADERO_ = 291,
    FALSO_ = 292,
    INSTREND_ = 293,
    SEP_ = 294,
    INC_ = 295,
    DEC_ = 296,
    ID_ = 297,
    CTE_ = 298
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 21 "src/asin.y"

	t_exp exp;
	int value;
	char *string;

#line 107 "asin.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ASIN_H_INCLUDED  */
