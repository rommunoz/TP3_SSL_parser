%code top{
#include <stdio.h>
#include "scanner.h"
#include "string.h"
int yylex(void);
}

%defines "parser.h"
%output "parser.c"
%define parse.error verbose

%token PR_VAR PR_SALIR NL ID NRO

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
    char*   id;
    double  nro;
};
extern int yylexerrs;
}

%define api.value.type {struct YYSTYPE}

%%

programa: sesion 				{if (yynerrs || yylexerrs) YYABORT;}
    ;
sesion 	: linea NL								
    | sesion linea NL			{printf("\n"); }
    ;
linea   : error
	| expresion					{printf("Expresión\n"); }
    | PR_VAR ID definicion
    | PR_SALIR					{printf("Palabra reservada salir\n");}
    ;
definicion : %empty				{printf("Define ID como variable\n");}
	| '=' expresion 			{printf("Define ID como variable con valor inicial\n");}
	;
expresion : aditiva
    | ID asignacion
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
	;
factor  : primaria potencia
	| '-' primaria %prec NEG	{printf("Cambio de signo\n"); }
    ;
potencia : %empty
	| '^' primaria				{printf("Potenciación\n"); /*revisar porque despues del menos debería ir un factor, pero existiría la posibilidad de escribir '------1' por ejemplo*/ }
	;
primaria : ID invocacion		
    | NRO					{printf("Número\n");}
    | '(' expresion ')'			{printf("Cierra paréntesis\n");}
    ;
invocacion : %empty             {printf("ID '%s'\n", yylval.id);}
    | '(' expresion ')'         {printf("Se llamó a la función '%s'\n", yylval.id); }
    ;

%%

void yyerror(const char *s){
	printf("línea #%d: %s\n", yylineno, s);
	return;
}