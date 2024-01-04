%{
#include <stdio.h>
#include <string.h>
#include "parser.h"
char msg[120];
%}
%option header-file="scanner.h"
%option outfile="scanner.c"

%option yylineno
%option noinput 
%option nounput
%option noyywrap
    //%option debug
                      
flotante            ([0-9]+([.][0-9]*)|[.][0-9]+)
letra               [a-zA-Z]
fueraDelAlfabeto    [[:punct:]]{-}[0-9a-zA-Z.()^=*+/-]
realInvalido        \.*{flotante}[a-zA-Z.][a-zA-Z0-9.]*
idInvalido          {letra}[a-zA-Z0-9]*{fueraDelAlfabeto}.*

%%

var                         {yylval.reserv = strdup(yytext); return PR_VAR;}
salir                       {yylval.reserv = strdup(yytext); return PR_SALIR;}
a?(cos|sin|tan)|log|sqrt    {yylval.func = strdup(yytext); return FUNCION;}
{letra}[a-zA-Z0-9]*         {yylval.id = strdup(yytext); return IDENTIFICADOR;}
\n                          {return NL;}
{flotante}|[0-9]+           {yylval.nro = atof(yytext); return NUMERO;}
-=                          return OP_MENOS_IG;
\+=                         return OP_MAS_IG;
\*=                         return OP_POR_IG;
\/=                         return OP_DIV_IG;
{idInvalido}                printf("Error léxico: Identificador inválido: '%s'\n", yytext);
[0-9]+{letra}[a-zA-Z0-9]*   printf("Error léxico: Constante inválida: '%s'\n", yytext);
{realInvalido}              printf("Error léxico: Real inválido: '%s'\n", yytext);
{fueraDelAlfabeto}+         printf("Error léxico: Cadena desconocida: '%s'\n", yytext);
[=^+/*()-]                  return yytext[0];
[ \t]                       //null;

%%