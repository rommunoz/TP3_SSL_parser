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
                      
flotante            ([0-9]+([.][0-9]*)|[.][0-9]+)
letra               [a-zA-Z]
fueraDelAlfabeto    [[:punct:]]{-}[0-9a-zA-Z.()^=*+/-]
realInvalido        \.*{flotante}[a-zA-Z.][a-zA-Z0-9.]*
idInvalido          {letra}[a-zA-Z0-9]*{fueraDelAlfabeto}.*

%%

var                         {return PR_VAR;}
salir                       {return PR_SALIR;}
{letra}[a-zA-Z0-9]*         {yylval.id = strdup(yytext); return ID;} 
\n                          {return NL;}
{flotante}|[0-9]+           {yylval.nro = atof(yytext); return NRO;}
-=                          return OP_MENOS_IG;
\+=                         return OP_MAS_IG;
\*=                         return OP_POR_IG;
\/=                         return OP_DIV_IG;
{idInvalido}                {yylexerrs++; printf("Error léxico: Identificador inválido: '%s'\n", yytext); return YYerror;}
[0-9]+{letra}[a-zA-Z0-9]*   {yylexerrs++; printf("Error léxico: Constante inválida: '%s'\n", yytext); return YYerror;}
{realInvalido}              {yylexerrs++; printf("Error léxico: Real inválido: '%s'\n", yytext); return YYerror;}
{fueraDelAlfabeto}+         {yylexerrs++; printf("Error léxico: Cadena desconocida: '%s'\n", yytext); return YYerror;}
[=^+/*()-]                  return yytext[0];
[ \t]                       //null;

%%