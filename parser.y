%code top{
#include <stdio.h>
#include "scanner.h"
#define DIM_TOKENS 6
int yylex(void);
char *token_names[DIM_TOKENS] = {"Fin de Archivo", "var", "salir", "NL", "Identificador", "Numero"};
}

%defines "parser.h"
%output "parser.c"

%token FDT PR_VAR PR_SALIR NL FUNCION IDENTIFICADOR NUMERO OP_MENOS_IG OP_MAS_IG OP_POR_IG OP_DIV_IG

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
}

%define api.value.type {struct YYSTYPE}

%type <reserv> PR_SALIR PR_VAR
%type <func> FUNCION
%type <id> IDENTIFICADOR
%type <nro> NUMERO

%%

prog 	: sesion
        ;
sesion 	: %empty
    | sesion linea NL 			{ printf("\n"); }
    ;
linea   : expresion 					 { printf("Expresión\n"); }
    | PR_VAR IDENTIFICADOR               { printf("Se declaró la variable '%s'\n", $<id>2); }
    | PR_VAR IDENTIFICADOR '=' expresion { printf("Se declaró la variable '%s' y se la incializó explicitamente con '%f'\n", $<id>2, $<nro>4); }
    | PR_SALIR							 { printf("Terminado el prog con la palabra reservada salir\n");}
    ;
expresion : aditiva
    | expresionConAsignacion
    ;
expresionConAsignacion : IDENTIFICADOR operadorAsignacion expresion {printf("Asignación\n", $<id>1);}
    ;
operadorAsignacion : '='
    | OP_MENOS_IG
    | OP_MAS_IG
    | OP_POR_IG
    | OP_DIV_IG
    ;
aditiva : termino
    | aditiva sumando 			{printf("Suma\n");}
    ;
sumando : '+' termino 
	| '-' termino
	;
termino : factor
    | termino multiplicador 	{ printf("Multiplicación\n");}
    ;
multiplicador : '*' factor  
	| '/' factor
factor  : potencia
    | '-' potencia %prec NEG	{ printf("Se usó el '-' unario\n");}
    ;
potencia : primaria potencia_
    ;
potencia_ : %empty
	| '^' primaria_				{ printf("Potenciación\n");}
	;
primaria_ : primaria
	| '-' primaria %prec NEG	{ printf("Se usó el '-' unario\n");}
	;
primaria : IDENTIFICADOR        { printf("ID '%s'\n", $<id>1);}
    | NUMERO                    { printf("Número '%f'\n", $<nro>1);}
    | '(' expresion ')'
    | FUNCION '(' expresion ')' { printf("Se llamó a la función '%s'\n", $<func>1); }
    ;

%%

void yyerror(const char *s){
	printf("línea #%d: %s\n", yylineno, s);
	return;
}