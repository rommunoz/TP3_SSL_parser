%code top{
#include <stdio.h>
#include <strings.h>
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
%precedence FUNCION
%precedence '(' ')'

%code provides {
void yyerror(const char *);
extern int yylexerrs;
}

%define api.value.type {char *}

%%

programa: sesion                { if (yynerrs || yylexerrs) YYABORT;}
    ;
sesion 	: linea                 { printf("\n"); }
    | sesion linea              { printf("\n"); }
    ;
linea   :  expresion NL         { printf("Expresión\n"); }
    | error NL
    | PR_VAR ID NL                  { printf("Define ID como variable\n");}
    | PR_VAR ID '=' expresion NL    { printf("Define ID como variable con valor inicial\n");}
    | PR_SALIR NL                   { printf("Palabra reservada salir\n"); return (yynerrs || yylexerrs);}
    ;
expresion : aditiva
    | ID '=' expresion          { printf("Asignación\n");}
    | ID OP_MENOS_IG expresion  { printf("Asignación con resta\n");}
    | ID OP_MAS_IG expresion    { printf("Asignación con suma\n");}
    | ID OP_POR_IG expresion    { printf("Asignación con multiplicación\n");}
    | ID OP_DIV_IG expresion    { printf("Asignación con división\n");}
    ;
aditiva : termino               
    | aditiva '+' termino       { printf("Suma\n");}			
    | aditiva '-' termino       { printf("Resta\n");}			
    ;
termino : factor                
    | termino '*' factor        { printf("Multiplicación\n");}
    | termino '/' factor        { printf("División\n");}
    ;
factor  : primaria_ '^' factor  { printf("Potenciación\n");}
    | primaria_                 
    ;
primaria_ : primaria            
    | '-' primaria  %prec NEG   { printf("Cambio de signo\n");}
    ;
primaria : ID                               { printf("ID\n");}
    | NRO                                   { printf("Número\n");}
    | '(' expresion ')'                     { printf("Cierra paréntesis\n");}
    | ID '(' expresion ')' %prec FUNCION    { printf("Llamado a función\n");}	
    ;

%%

void yyerror(const char *s){
	printf("línea #%d: %s\n", yylineno, s);
	return;
}