%code top{
#include <stdio.h>
#include <string.h>
#include "scanner.h"
int yylex(void);
}
%defines "parser.h"
%output "parser.c"
%define parse.error verbose

%token PR_VAR PR_SALIR NL ID NRO

%right 	'=' OP_MAS_IG OP_MENOS_IG OP_POR_IG OP_DIV_IG
%left 	'-' '+'
%left 	'*' '/'
%right 	'^'
%precedence NEG

%code provides {
void yyerror(const char *);
extern int yylexerrs;
}

%define api.value.type {char *}

%%

programa: sesion                    { if (yynerrs || yylexerrs) YYABORT;}
    ;
sesion 	: linea                     { printf("\n"); }
    | sesion linea                  { printf("\n"); }
    ;
linea   :  sentencia NL             { printf("Expresión\n"); }
    | error NL
    | PR_VAR ID NL                  { printf("Define ID como variable\n");}
    | PR_VAR ID '=' expresion NL    { printf("Define ID como variable con valor inicial\n");}
    | PR_SALIR NL                   { printf("Palabra reservada salir\n\n"); return (yynerrs || yylexerrs);}
    ;
sentencia : expresion
    | ID '=' sentencia              { printf("Asignación\n"); }
    | ID OP_MAS_IG sentencia        { printf("Asignación con suma\n"); }
    | ID OP_MENOS_IG sentencia      { printf("Asignación con resta\n"); }
    | ID OP_POR_IG sentencia        { printf("Asignación con multiplicación\n"); }
    | ID OP_DIV_IG sentencia        { printf("Asignación con división\n"); }
    ;
expresion : ID                      { printf("ID\n");}
    | NRO                           { printf("Número\n");}
    | expresion '+' expresion       { printf("Suma\n");}			
    | expresion '-' expresion       { printf("Resta\n");}	
    | expresion '*' expresion       { printf("Multiplicación\n");}
    | expresion '/' expresion       { printf("División\n");}
    | expresion '^' expresion       { printf("Potenciación\n");}
    | '-' expresion  %prec NEG      { printf("Cambio de signo\n");}
    | '(' expresion ')'             { printf("Cierra paréntesis\n");}
    | ID '(' expresion ')'          { printf("Llamado a función\n");}
    ;


%%

void yyerror(const char *s){
	printf("línea #%d: %s\n", yylineno, s);
	return;
}