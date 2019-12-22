/*
	example.y

 	Example of a bison specification file.

	Grammar is:

        <expr> -> intconst | ident | foo <identList> 
                  <intconstList>
        <identList> -> lambda | <identList> ident
        <intconstList> -> intconst | <intconstList> intconst

      To create the syntax analyzer:

        flex example.l
        bison example.y
        g++ example.tab.c -o parser
        parser < inputFileName
 */

%{
#include <stdio.h>

int numLines = 1; 

void printRule(const char *, const char *);
int yyerror(const char *s);
void printTokenInfo(const char* tokenType, const char* lexeme);

extern "C" 
{
    int yyparse(void);
    int yylex(void);
    int yywrap() { return 1; }
}

%}

/* Token declarations */
%token T_IDENT
%token T_INTCONST
%token T_UNKNOWN
%token T_FOO
%token T_OR
%token T_STRCONST
%token T_SEMICOLON
%token T_WHILE
%token T_TRUE
%token T_POWER
%token T_MULT
%token T_PRINT
%token T_IF
//%token T_ELSE
%token T_FLOATCONST
%token T_GE
%token T_DIV
%token T_EQ
%token T_FALSE
//%token T_RPAREN
%token T_RBRACKET
%token T_AND
%token T_LIST
%token T_LPAREN
%token T_COMMA
%token T_LBRACE
%token T_GT
%token T_ADD
%token T_RBRACE
%token T_IN
%token T_NEXT
%token T_LT
%token T_NE
%token T_SUB
%token T_POW
%token T_FOR
%token T_BREAK
%token T_FUNCTION
%token T_ASSIGN
%token T_NOT
%token T_CAT
%token T_READ
%token T_MOD
%token T_LE
%token T_LBRACKET
%token T_QUIT	

%nonassoc T_RPAREN
%nonassoc T_ELSE

/* Starting point */
%start		N_START

/* Translation rules */
%%
N_START	: N_EXPR
			{
				printRule("START", "EXPR");
				printf("\n---- Completed parsing ----\n\n");
				return 0;
			};


N_EXPR : 
				N_IF_EXPR 
				{
					printRule("EXPR","IF_EXPR");
				}

				| N_WHILE_EXPR
				{
					printRule("EXPR","WHILE_EXPR");
				} 

				| N_FOR_EXPR
				{
					printRule("EXPR","FOR_EXPR");
				} 

				| N_COMPOUND_EXPR
				{
					printRule("EXPR","COMPOUND_EXPR");
				} 

				| N_ARITHLOGIC_EXPR 
				{
					printRule("EXPR", "ARITHLOGIC_EXPR");
				}

				| N_ASSIGNMENT_EXPR
				{
					printRule("EXPR","ASSIGNMENT_EXPR");
				} 

				| N_OUTPUT_EXPR
				{
					printRule("EXPR","OUTPUT_EXPR");
				} 

				| N_INPUT_EXPR
				{
					printRule("EXPR","INPUT_EXPR");
				} 

				| N_LIST_EXPR
				{
					printRule("EXPR","LIST_EXPR");
				} 

				| N_FUNCTION_DEF
				{
					printRule("EXPR","FUNCTION_DEF");
				} 

				| N_FUNCTION_CALL
				{
					printRule("EXPR","FUNCTION_CALL");
				} 

				| N_QUIT_EXPR
				{
					printRule("EXPR","QUIT_EXPR");
					exit(1);
				};

N_CONST : 
				T_INTCONST
				{
					printRule("CONST", "INTCONST");
				} 

				| T_STRCONST 
				{
					printRule("CONST", "STRCONST");
				}

				| T_FLOATCONST
				{
					printRule("CONST", "FLOATCONST");
				} 

				| T_TRUE
				{
					printRule("CONST","TRUE");
				} 

				| T_FALSE
				{
					printRule("CONST","FALSE");
				};

N_COMPOUND_EXPR :
				T_LBRACE N_EXPR N_EXPR_LIST T_RBRACE
				{
					printRule("COMPOUND_EXPR","{ EXPR EXPR_LIST }");
				};

N_EXPR_LIST : 
				T_SEMICOLON N_EXPR N_EXPR_LIST 
				{
					printRule("EXPR_LIST","; EXPR EXPR_LIST");
				}
				| /* epsilon */
				{
					printRule("EXPR_LIST","epsilon");
				};

N_IF_EXPR : 
				T_IF T_LPAREN N_EXPR T_RPAREN N_EXPR 
				{
					printRule("IF_EXPR","IF ( EXPR ) EXPR");
				}
				| T_IF T_LPAREN N_EXPR T_RPAREN N_EXPR T_ELSE N_EXPR
				{
					printRule("IF_EXPR","IF ( EXPR ) EXPR ELSE EXPR");
				};

N_WHILE_EXPR :
				T_WHILE T_LPAREN N_EXPR T_RPAREN N_LOOP_EXPR
				{
					printRule("WHILE_EXPR","WHILE ( EXPR ) LOOP_EXPR");
				};

N_FOR_EXPR : 
				T_FOR T_LPAREN T_IDENT T_IN N_EXPR T_RPAREN N_LOOP_EXPR
				{
					printRule("FOR_EXPR", "FOR ( IDENT IN EXPR ) LOOP_EXPR");
				};

N_LOOP_EXPR :
				N_EXPR 
				{
					printRule("LOOP_EXPR","EXPR");
				}

				| N_BREAK_EXPR
				{
					printRule("LOOP_EXPR","BREAK_EXPR");
				}

				| N_NEXT_EXPR
				{
					printRule("LOOP_EXPR","NEXT_EXPR");
				};

N_BREAK_EXPR : 
				T_BREAK
				{
					printRule("BREAK_EXPR","BREAK");
				};
N_NEXT_EXPR : 
				T_NEXT
				{
					printRule("NEXT_EXPR", "NEXT");
				};

N_LIST_EXPR : 
				T_LIST T_LPAREN N_CONST_LIST T_RPAREN
				{
					printRule("LIST_EXPR","LIST ( CONST_LIST )");
				};

N_CONST_LIST : 
				N_CONST T_COMMA N_CONST_LIST 
				{
					printRule("CONST_LIST","CONST, CONST_LIST");
				}

				| N_CONST
				{
					printRule("CONST_LIST", "CONST");
				};

N_ASSIGNMENT_EXPR : 
				T_IDENT N_INDEX T_ASSIGN N_EXPR
				{
					printRule("ASSIGNMENT_EXPR","IDENT INDEX ASSIGN EXPR");
				};

N_INDEX : 
				T_LBRACKET T_LBRACKET N_EXPR T_RBRACKET T_RBRACKET 
				{
					printRule("INDEX","[[ EXPR ]]");
				}
				| /* epsilon */
				{
					printRule("INDEX", " epsilon");
				};

N_QUIT_EXPR : 
				T_QUIT T_LPAREN T_RPAREN
				{
					printRule("QUIT_EXPR","QUIT()");
				};


N_OUTPUT_EXPR : 
				T_PRINT T_LPAREN N_EXPR T_RPAREN 
				{
					printRule("OUTPUT_EXPR","PRINT ( EXPR )");
				}

				| T_CAT T_LPAREN N_EXPR T_RPAREN
				{
					printRule("OUTPUT_EXPR","CAT ( EXPR )");
				};

N_INPUT_EXPR : 
				T_READ T_LPAREN N_VAR T_RPAREN
				{
					printRule("INPUT_EXPR", "READ ( VAR )");
				};

N_FUNCTION_DEF : 
				T_FUNCTION T_LPAREN N_PARAM_LIST T_RPAREN N_COMPOUND_EXPR
				{
					printRule("FUNCTION_DEF", "FUNCTION ( PARAM_LIST ) COMPOUND_EXPR");
				};

N_PARAM_LIST : 
				N_PARAMS 
				{
					printRule("PARAM_LIST", "PARAMS");
				}

				| N_NO_PARAMS
				{
					printRule("PARAM_LIST","NO_PARAMS");
				};

N_NO_PARAMS : 
				/* epsilon */
				{
					printRule("NO_PARAMS","epsilon");
				};

N_PARAMS : 
				T_IDENT
				{
					printRule("PARAMS","IDENT");
				}

				| T_IDENT T_COMMA N_PARAMS
				{
					printRule("PARAMS","IDENT, PARAMS");
				};

N_FUNCTION_CALL :
				T_IDENT T_LPAREN N_ARG_LIST T_RPAREN
				{
					printRule("FUNCTION_CALL","IDENT ( ARG_LIST )");
				};

N_ARG_LIST : 
				N_ARGS 
				{
					printRule("ARG_LIST","ARGS");
				}

				| N_NO_ARGS
				{
					printRule("ARG_LIST","NO_ARGS");
				};

N_NO_ARGS : 
				/* epsilon */
				{
					printRule("NO_ARGS","epsilon");
				};

N_ARGS : 
				N_EXPR 
				{
					printRule("ARGS","EXPR");
				}

				| N_EXPR T_COMMA N_ARGS
				{
					printRule("ARGS","EXPR, ARGS");
				};


N_ARITHLOGIC_EXPR : 
				N_SIMPLE_ARITHLOGIC 
				{
					printRule("ARITHLOGIC_EXPR", "SIMPLE_ARITHLOGIC");
				}

				| N_SIMPLE_ARITHLOGIC N_REL_OP N_SIMPLE_ARITHLOGIC
				{
					printRule("ARITHLOGIC_EXPR","SIMPLE_ARITHLOGIC REL_OP SIMPLE_ARITHLOGIC");
				};

N_SIMPLE_ARITHLOGIC : 
				N_TERM N_ADD_OP_LIST
				{
					printRule("SIMPLE_ARITHLOGIC", "TERM ADD_OP_LIST");
				};

N_ADD_OP_LIST : 
				N_ADD_OP N_TERM N_ADD_OP_LIST
				{
					printRule("ADD_OP_LIST", "ADD_OP TERM ADD_OP_LIST");
				} 

				| /* epsilon */
				{
					printRule("ADD_OP_LIST","epsilon");
				};

N_TERM : 
				N_FACTOR N_MULT_OP_LIST
				{
					printRule("TERM", "FACTOR MULT_OP_LIST");
				};

N_MULT_OP_LIST : 
				N_MULT_OP N_FACTOR N_MULT_OP_LIST 
				{
					printRule("MULT_OP_LIST", "MULT_OP FACTOR MULT_OP_LIST");
				}

				| /* epsilon */
				{
					printRule("MULT_OP_LIST","epsilon");
				};

N_FACTOR : 
				N_VAR 
				{
					printRule("FACTOR","VAR");
				}

				| N_CONST 
				{
					printRule("FACTOR","CONST");
				}

				| T_LPAREN N_EXPR T_RPAREN 
				{
					printRule("FACTOR","( EXPR )");
				}

				| T_NOT N_FACTOR
				{
					printRule("FACTOR","! FACTOR");
				};

N_ADD_OP : 
				T_ADD 
				{
					printRule("ADD_OP","+");
				}

				| T_SUB
				{
					printRule("ADD_OP","-");
				} 

				| T_OR
				{
					printRule("ADD_OP","|");
				};

N_MULT_OP : 
				T_MULT 
				{
					printRule("MULT_OP","*");
				}

				| T_DIV
				{
					printRule("MULT_OP","/");
				} 

				| T_AND
				{
					printRule("MULT_OP","&");
				} 

				| T_MOD
				{
					printRule("MULT_OP","%%");
				} 

				| T_POW
				{
					printRule("MULT_OP","^");
				};

N_REL_OP : 
				T_LT 
				{
					printRule("REL_OP","<");
				}

				| T_GT
				{
					printRule("REL_OP",">");
				}

				| T_LE
				{
					printRule("REL_OP","<=");
				} 

				| T_GE
				{
					printRule("REL_OP",">=");
				} 

				| T_EQ
				{
					printRule("REL_OP","==");
				} 
				| T_NE
				{
					printRule("REL_OP","!=");
				};

N_VAR : 
				N_ENTIRE_VAR 
				{
					printRule("VAR","ENTIRE_VAR");
				}

				| N_SINGLE_ELEMENT
				{
					printRule("VAR","SINGLE_ELEMENT");
				};

N_SINGLE_ELEMENT : 
				T_IDENT T_LBRACKET T_LBRACKET N_EXPR T_RBRACKET T_RBRACKET
				{
					printRule("SINGLE_ELEMENT", "IDENT [[ EXPR ]]");
				};

N_ENTIRE_VAR : 
				T_IDENT
				{
					printRule("ENTIRE_VAR","IDENT");
				};


%%
#include "lex.yy.c"
extern FILE *yyin;

void printRule(const char *lhs, const char *rhs) 
{
  printf("%s -> %s\n", lhs, rhs);
  return;
}


int yyerror(const char *s) 
{
  printf("Line %d: ", numLines);
  printf("%s\n", s);
  exit(1);
}


void printTokenInfo(const char* tokenType, const char* lexeme) 
{
	printf("TOKEN: %s \t\t LEXEME: %s\n", tokenType, lexeme);
}


int main() 
{
  do 
  {
		yyparse();
  } while (!feof(yyin));

  //printf("%d lines processed\n", numLines);
  return(0);
}
