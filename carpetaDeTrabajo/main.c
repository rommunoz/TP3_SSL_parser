#include <stdio.h>
#include "scanner.h"
#include "parser.h"
#define DIM_TOKENS 6

int yylexerrs = 0;
int main(void){
    switch( yyparse() ){
    	case 0:
		    puts("Pertenece al LIC"); return 0;
    	case 1:
		    puts("No pertenece al LIC"); return 1;
    	case 2:
		    puts("Memoria insuficiente"); return 2;
	    }
}