%code top{
#include <stdio.h>
#include "scanner.h"
#define DIM_TOKENS 6
int yylex(void);
}

%defines "parser.h"
%output "parser.c"
%define parse.error verbose

%token FDT PR_VAR PR_SALIR NL IDENTIFICADOR NUMERO

%right '=' OP_MAS_IG OP_MENOS_IG OP_POR_IG OP_DIV_IG
%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'
%precedence FUNCION
%precedence '(' ')'

%code provides {
void yyerror(const char *);
struct YYSTYPE {
    char* reserv;
    char* func;
    char* id;
    double nro;
};
extern int yylexerrs;
}

%define api.value.type {struct YYSTYPE}

%%

prog 	: sesion 				{if (yynerrs || yylexerrs) YYABORT;}
    ;
sesion 	: linea NL				{printf("\n"); }
    | sesion linea NL			{printf("\n"); }
    ;
linea   : expresion				{printf("Expresión\n"); }
    | PR_VAR IDENTIFICADOR definicion
    | PR_SALIR					{printf("Terminado el prog con la palabra reservada salir\n");}
    ;
definicion : %empty				{printf("Define ID como variable\n");}
	| '=' expresion 			{printf("Define ID como variable con valor inicial\n");}
	;
expresion : aditiva
    | IDENTIFICADOR asignacion
    ;
asignacion : '=' expresion		{printf("Asignación\n");}
    | OP_MENOS_IG expresion		{printf("Asignación con resta\n");}
    | OP_MAS_IG expresion		{printf("Asignación con suma\n");}
    | OP_POR_IG expresion		{printf("Asignación con multiplicación\n");}
    | OP_DIV_IG expresion		{printf("Asignación con división\n");}
    ;
aditiva : termino
    | aditiva sumando			
    ;
sumando : '+' termino			{printf("Suma\n");}
	| '-' termino				{printf("Resta\n");}
	;
termino : factor
    | termino multiplicador 	
    ;
multiplicador : '*' factor		{printf("Multiplicación\n");}
	| '/' factor				{printf("División\n");}
factor  : potencia
    | '-' potencia %prec NEG	{printf("Se usó el '-' unario\n");}
    ;
potencia : primaria potencia_
    ;
potencia_ : %empty
	| '^' primaria_				{printf("Potenciación\n");}
	;
primaria_ : primaria
	| '-' primaria %prec NEG	{printf("Se usó el '-' unario\n");}
	;
primaria : IDENTIFICADOR		{printf("ID '%s'\n", $<id>1);}
    | NUMERO					{printf("Número\n");}
    | '(' expresion ')'			{printf("Cierra paréntesis\n");}
    | FUNCION '(' expresion ')'	{printf("Se llamó a la función '%s'\n", $<func>1); }
    ;

%%

void yyerror(const char *s){
	printf("línea #%d: %s\n", yylineno, s);
	return;
}