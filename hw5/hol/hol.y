/* 
    minir.y

    flex minir.l
    bison minir.y
    g++ minir.tab.c -o parser
    ./parser < inputFileName
    
*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <string.h>
#include <stack>
#include <iomanip> 
#include <cmath>
#include "SymbolTable.h"
using namespace std;

#define ARITHMETIC_OP   1
#define LOGICAL_OP      2
#define RELATIONAL_OP   3
#define INDEX_PROD      4
#define NOT_INDEX_PROD  5

#define ADD 6
#define SUB 7
#define OR 8
#define MULT 9
#define DIV 10
#define AND 11
#define MOD 12
#define POW 13
#define LT 14
#define GT 15
#define LE 16
#define GE 17
#define EQ 18
#define NE 19
 


#define ERR_CANNOT_BE_FUNCT_NULL_LIST_OR_STR	0
#define ERR_CANNOT_BE_FUNCT					1 
#define ERR_CANNOT_BE_FUNCT_OR_NULL			2
#define ERR_CANNOT_BE_FUNCT_OR_NULL_OR_LIST		3
#define ERR_CANNOT_BE_LIST					4 
#define ERR_MUST_BE_LIST					5
#define ERR_MUST_BE_FUNCT					6
#define ERR_MUST_BE_INTEGER					7
#define ERR_MUST_BE_INT_FLOAT_OR_BOOL			8
#define ERR_TOO_FEW_PARAMS					9
#define ERR_TOO_MANY_PARAMS					10
#define ERR_NON_INT_FUNCT_PARAM				11
#define ERR_MULTIPLY_DEFINED_IDENT			12
#define ERR_UNDEFINED_IDENT					13
#define ERR_ERROR						14
#define ERR_SUB_OUT_OF_BOUNDS   15
#define ERR_ATTEMPTED_DIV_BY_ZERO   16

const int NUM_ERR_MESSAGES = 17;  // should be ERR_ERROR + 1

const string ERR_MSG[NUM_ERR_MESSAGES] = {
"cannot be function or null or list or string",
"cannot be function",
"cannot be function or null",
"cannot be function or null or list",
"cannot be list",
"must be list",
"must be function",
"must be integer",
"must be integer or float or bool",
"Too few parameters in function call",
"Too many parameters in function call",
"Function parameters must be integer",
"Multiply defined identifier",
"Undefined identifier",
"<undefined error>",
"Subscript out of bounds",
"Attempted division by zero"
};

// constant to suppress token printing
const bool suppressTokenOutput = true;

int line_num = 1;
int numExprs = 0;

stack<SYMBOL_TABLE> scopeStack; // stack of scope hashtables

bool isIntOrFloatOrBoolCompatible(const int theType);
bool isIntCompatible(const int theType);
bool isBoolCompatible(const int theType);
bool isFloatCompatible(const int theType);
bool isListCompatible(const int theType);
bool isInvalidOperandType(const int theType);

void beginScope();
void endScope();
void cleanUp();
TYPE_INFO findEntryInAnyScope(const string the_name);

void semanticError(const int argNum, const int errNum);

void printTokenInfo(const char* token_type, const char* lexeme);

void printRule(const char *, const char *);

int yyerror(const char *s) 
{
    printf("Line %d: %s\n", line_num, s);
    cleanUp();
    exit(1);
}

extern "C" 
{
    int yyparse(void);
    int yylex(void);
    int yywrap() { return 1; }
}

%}

%union {
    char* text;
    int num;
    int intValue;
    float floatValue;
    bool boolValue;
    bool flag;
    TYPE_INFO typeInfo;
};

%token T_IDENT T_INTCONST T_FLOATCONST T_UNKNOWN T_STRCONST 
%token T_IF T_ELSE
%token T_WHILE T_FUNCTION T_FOR T_IN T_NEXT T_BREAK 
%token T_TRUE T_FALSE T_QUIT
%token T_PRINT T_CAT T_READ T_LPAREN T_RPAREN T_LBRACE 
%token T_RBRACE T_LBRACKET
%token T_RBRACKET T_SEMICOLON T_COMMA T_ADD T_SUB 
%token T_MULT T_DIV T_MOD
%token T_POW T_LT T_LE T_GT T_GE T_EQ T_NE T_NOT T_AND 
%token T_OR T_ASSIGN T_LIST

%type <text> T_IDENT T_STRCONST

%type <typeInfo> N_EXPR N_IF_EXPR N_THEN_EXPR N_COND_IF 
%type <typeInfo> N_COMPOUND_EXPR N_ARITHLOGIC_EXPR
%type <typeInfo> N_ASSIGNMENT_EXPR N_FOR_EXPR N_WHILE_EXPR 
%type <typeInfo> N_INPUT_EXPR N_OUTPUT_EXPR N_LIST_EXPR
%type <typeInfo> N_FUNCTION_DEF N_FUNCTION_CALL
%type <typeInfo> N_QUIT_EXPR N_CONST N_EXPR_LIST
%type <typeInfo> N_SIMPLE_ARITHLOGIC N_TERM N_ADD_OP_LIST
%type <typeInfo> N_FACTOR N_MULT_OP_LIST N_VAR N_CONST_LIST
%type <typeInfo> N_SINGLE_ELEMENT N_ENTIRE_VAR N_INDEX


%type <num> N_REL_OP N_ADD_OP N_MULT_OP
%type <num> N_ARG_LIST N_ARGS

%type <intValue> T_INTCONST 
%type <floatValue> T_FLOATCONST 
%type <boolValue> T_TRUE T_FALSE

/*
 *  To eliminate ambiguity in if/else
 */
%nonassoc   T_RPAREN 
%nonassoc   T_ELSE


%start N_START

%%

N_START:        N_EXPR
                {
                    printRule("START", "EXPR");
                    printf("\n---- Completed parsing ----\n\n");
                    printf("Value of the expression is: ");
                    
                    
                    //cout << "\nN_START = " << $1.value.intValue << endl;
                    //cout << "float=" << $1.value.floatValue <<endl;
                    //cout << "string=" << $1.value.stringValue << endl;
                    //cout << "bool=" << $1.value.boolValue << endl;
                    //cout << "valuetype=" << $1.value.type << endl;
                    //cout << "typetyep =" << $1.type <<endl;
                    
                    
                    switch($1.type)
                    {
                        case NULL_TYPE:
                            cout << "NULL" << endl;
                            break;
                        case INT:
                            cout << $1.value.intValue;
                            //cout <<"$$$inside int =" <<endl; ;
                            break;
                        case STR:
                            cout << $1.value.stringValue;
                            break;
                        case BOOL:
                            if($1.value.boolValue)
                            {
                                cout << "TRUE";   
                            }
                            else
                            {
                                cout << "FALSE";
                            }
                            break;
                        case FLOAT:
                            cout << fixed << setprecision(2) << $1.value.floatValue; 
                            break;
                        case LIST:
                            cout << "( ";
                            for (list<TYPE>::const_iterator itr = $1.listValue->begin(), end = $1.listValue->end(); itr != end; ++itr) 
                            {
                                if(itr->type == INT)
                                {
                                    cout << itr->intValue;
                                }
                                else if(itr->type == STR)
                                {
                                    cout << itr->stringValue;
                                }
                                else if(itr->type == BOOL)
                                {
                                    if(itr->boolValue)
                                    {
                                        cout << "TRUE";
                                    }
                                    else
                                    {
                                        cout << "FALSE";
                                    }
                                }
                                else if(itr->type == FLOAT)
                                {
                                    cout << fixed << setprecision(2)<< itr->floatValue;
                                }
                                cout << " ";
                            }
                            cout << ")";
                            break;
                        case FUNCTION:
                            break;
                        default:
                            cout << "reaches default case";
                            break;
                    }

                    return 0;
                }
                ;
N_EXPR:         N_IF_EXPR
                {
                    printRule("EXPR", "IF_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_WHILE_EXPR
                {
                    printRule("EXPR", "WHILE_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_FOR_EXPR
                {
                    printRule("EXPR", "FOR_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_COMPOUND_EXPR
                {
                    printRule("EXPR", "COMPOUND_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_ARITHLOGIC_EXPR
                {
                    printRule("EXPR", "ARITHLOGIC_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    //$$.value.intValue = $1.value.intValue;
                    $$.listValue = $1.listValue;  
                    //cout << "N_EXPR =" << $$.value.intValue << endl;
                }
                | N_ASSIGNMENT_EXPR
                {
                    printRule("EXPR", "ASSIGNMENT_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_OUTPUT_EXPR
                {
                    printRule("EXPR", "OUTPUT_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_INPUT_EXPR
                {
                    printRule("EXPR", "INPUT_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    //$$.value.intValue = $1.value.intValue;
                    //cout <<"N_EXPR="<< $$.value.intValue << endl;
                    $$.listValue = $1.listValue;
                }
                | N_LIST_EXPR
                {
                    printRule("EXPR", "LIST_EXPR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                    //cout << $$.listValue;
                }
                | N_FUNCTION_DEF
                {
                    printRule("EXPR", "FUNCTION_DEF");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_FUNCTION_CALL
                {
                    printRule("EXPR", "FUNCTION_CALL");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_QUIT_EXPR
                {
                    printRule("EXPR", "QUIT_EXPR");
                    $$.type = $1.type;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                    exit(1);
                }
                ;

N_CONST:        T_INTCONST
                {
                    printRule("CONST", "INTCONST");
                    $$.type = INT;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value.intValue =  $<intValue>1;
                    $$.value.type = INT;
                    //cout <<"intCONST =" << $$.value.intValue;
                }
                | T_STRCONST
                {
                    printRule("CONST", "STRCONST");
                    $$.type = STR;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    strcpy($$.value.stringValue, $<text>1);
                    $$.value.type = STR;

                }
                | T_FLOATCONST
                {
                    printRule("CONST", "FLOATCONST");
                    $$.type = FLOAT;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value.floatValue =  $<floatValue>1;
                    $$.value.type = FLOAT;
                }
                | T_TRUE
                {
                    printRule("CONST", "TRUE");
                    $$.type = BOOL;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value.boolValue =  $<boolValue>1;
                    $$.value.type = BOOL;
                }
                | T_FALSE
                {
                    printRule("CONST", "FALSE");
                    $$.type = BOOL;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value.boolValue =  $<boolValue>1;
                    $$.value.type = BOOL;
                }
                ;

N_COMPOUND_EXPR: T_LBRACE N_EXPR N_EXPR_LIST T_RBRACE
                {
                    printRule("COMPOUND_EXPR", "{ EXPR EXPR_LIST }");
			        if ($3.type == NOT_APPLICABLE)
			        {
				        $$.type = $2.type;
				        $$.numParams = $2.numParams;
				        $$.returnType = $2.returnType;
				        $$.isParam = $2.isParam;
                        $$.value = $2.value;
                        $$.listValue = $2.listValue;

			        }
			        else
			        {
				        $$.type = $3.type;
				        $$.numParams = $3.numParams;
				        $$.returnType = $3.returnType;
				        $$.isParam = $3.isParam;
                        $$.value = $3.value;
                        $$.listValue = $3.listValue;
			        }
                }
                ;

N_EXPR_LIST:    T_SEMICOLON N_EXPR N_EXPR_LIST
                {
                    printRule("EXPR_LIST", "; EXPR EXPR_LIST");
			        if ($3.type == NOT_APPLICABLE)
			        {
				        $$.type = $2.type;
				        $$.numParams = $2.numParams;
				        $$.returnType = $2.returnType;
				        $$.isParam = $2.isParam;
                        $$.value = $2.value;
                        $$.listValue = $2.listValue;
			        }
			        else
			        {
				        $$.type = $3.type;
				        $$.numParams = $3.numParams;
			        	$$.returnType = $3.returnType;
				        $$.isParam = $3.isParam;
                        $$.value = $2.value;
                        $$.listValue = $2.listValue;
			        }
                }
                | /* epsilon */
                {
                    printRule("EXPR_LIST", "epsilon");
                    $$.type = NOT_APPLICABLE;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                }
                ;

N_IF_EXPR:      N_COND_IF T_RPAREN N_THEN_EXPR 
                {
                    printRule("IF_EXPR", "IF ( EXPR ) EXPR");
                    $$.type = $3.type;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = $3.isParam;
                    if($1.value.boolValue != 0)
                    {
                        $$.value = $3.value;
                    }
                    else
                    {
                        $$.type = NULL_TYPE;
                    }
			    }
                | N_COND_IF T_RPAREN N_THEN_EXPR T_ELSE N_EXPR 
                {
                    printRule("IF_EXPR","IF ( EXPR ) EXPR ELSE EXPR");
                    if($5.type == FUNCTION)
                        semanticError(3, ERR_CANNOT_BE_FUNCT);
                    $$.type = $3.type ^ $5.type;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = $3.isParam || $5.isParam;

                    if($1.value.boolValue != 0)
                    {
                        $$.value = $3.value;
                        $$.type = $3.value.type;
                    }
                    else
                    {
                        $$.value = $5.value;
                        $$.type = $5.value.type;
                    }



			    }
                ;

N_COND_IF:      T_IF T_LPAREN N_EXPR 
			    {
                    if(($3.type == FUNCTION) 
                    || ($3.type == LIST)
                    || ($3.type == NULL_TYPE) 
                    || ($3.type == STR)) 
                        semanticError(1, ERR_CANNOT_BE_FUNCT_NULL_LIST_OR_STR);
                    $$.value = $3.value;
			    }
			    ; 

N_THEN_EXPR:    N_EXPR
			    {
                    if($1.type == FUNCTION)
                        semanticError(2, ERR_CANNOT_BE_FUNCT);
                    $$.type = $1.type;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;

			    }
			    ;

N_WHILE_EXPR:   T_WHILE T_LPAREN N_EXPR
                {
                    printRule("WHILE_EXPR", "WHILE ( EXPR ) EXPR");
                    if(($3.type == FUNCTION) 
                    || ($3.type == LIST)
                    || ($3.type == NULL_TYPE) 
                    || ($3.type == STR)) 
                        semanticError(1, ERR_CANNOT_BE_FUNCT_NULL_LIST_OR_STR);
                }
                T_RPAREN N_EXPR
                {
                    $$.type = $6.type;
                    $$.numParams = $6.numParams;
                    $$.returnType = $6.returnType;
                    $$.isParam = $6.isParam;
                }
                ;

N_FOR_EXPR:     T_FOR T_LPAREN T_IDENT 
                {
                    printRule("FOR_EXPR", "FOR ( IDENT IN EXPR ) EXPR");
                    string lexeme = string($3);
                    TYPE_INFO exprTypeInfo = scopeStack.top().findEntry(lexeme);
                    if(exprTypeInfo.type == UNDEFINED) 
                    {
                        if(!suppressTokenOutput)
                            printf("___Adding %s to symbol" " table\n", $3);
                        scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme,
                            {INT_OR_STR_OR_FLOAT_OR_BOOL, NOT_APPLICABLE, NOT_APPLICABLE,false}));
			        }
			        else
			        {     
			            if( (exprTypeInfo.type == FUNCTION) 
                        ||(exprTypeInfo.type == NULL_TYPE) 
                        ||(exprTypeInfo.type == LIST))
				            semanticError(1,ERR_CANNOT_BE_FUNCT_OR_NULL_OR_LIST);
			        }
                }
			    T_IN N_EXPR
			    {
                    if($6.type != LIST) 
				        semanticError(2, ERR_MUST_BE_LIST);
			    } 
			    T_RPAREN N_EXPR
			    {
                    $$.type = $9.type;
                    $$.numParams = $9.numParams;
                    $$.returnType = $9.returnType;
                    $$.isParam = $9.isParam;
			    }
                ;

N_LIST_EXPR:    T_LIST T_LPAREN N_CONST_LIST T_RPAREN
                {
                    printRule("LIST_EXPR", "LIST ( CONST_LIST )");
                    $$.type = LIST;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value = $3.value;
                    $$.listValue = new list<TYPE>;

                    $$.listValue = $3.listValue;
                    //cout <<"size of N_LIST_EXPR = " <<$$.listValue->size() << endl;
                    //for (list<TYPE>::const_iterator itr = $3.listValue->begin(), end = $3.listValue->end(); itr != end; ++itr) 
                    //{
                    //    $$.listValue->push_back(*itr);
                   // }
                    
                }
                ;

N_CONST_LIST:   N_CONST T_COMMA N_CONST_LIST
                {
                    printRule("CONST_LIST", "CONST, CONST_LIST");
                    $$.type = LIST;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $3.listValue;

                    //$1.listValue->push_back($1.value);
                    //$1.listValue->front();
                    //cout << "N_const_list =" <<$1.value.intValue << endl;

                    $$.listValue->push_front($1.value);
                    //cout<<"size = " <<$$.listValue->size() << endl;
                    //for (list<TYPE>::const_iterator itr = $$.listValue->begin(), end = $$.listValue->end(); itr != end; ++itr) 
                    //{
                    //    cout << "what is inside list="<<itr->intValue <<endl;
                    //}
                    
                }
                | N_CONST
                {
                    printRule("CONST_LIST", "CONST");
                    $$.type = LIST;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    //cout <<"liem";
                    //cout <<"N_CONST="<< $1.value.intValue << endl;
                    $$.listValue = new list<TYPE>;
                    $$.listValue->push_front($1.value);
                    //$$.listValue->front();
                    
                    //for (list<TYPE>::const_iterator itr = $$.listValue->begin(), end = $$.listValue->end(); itr != end; ++itr) 
                    //{
                    //    cout << itr->intValue;
                    //}


                    //cout << $$.listValue->size();
                    //$$.listValue($1.listValue);
                }
                ;

N_ASSIGNMENT_EXPR: T_IDENT N_INDEX
                {
                    printRule("ASSIGNMENT_EXPR", "IDENT INDEX ASSIGN EXPR");
                    string lexeme = string($1);
                    TYPE_INFO exprTypeInfo = scopeStack.top().findEntry(lexeme);
                    if(exprTypeInfo.type == UNDEFINED) 
			        {
                        if(!suppressTokenOutput)
                            printf("___Adding %s to symbol table\n", $1);
                        // add in as N/A type until the
                        // N_EXPR can be processed below to 
                        // get the correct type
                        scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme,
                            {NOT_APPLICABLE, NOT_APPLICABLE,NOT_APPLICABLE, false}));
                        // set flag that ident didn't already 
				        // exist
			            $<flag>$ = false;
                    }
                    else 
			        {
                        // set flag that ident already existed
				        $<flag>$ = true;
                    }
                }
                T_ASSIGN N_EXPR
                {
                    string lexeme = string($1);
                    TYPE_INFO exprTypeInfo = scopeStack.top().findEntry(lexeme);
                    if(($2.type == INDEX_PROD) && (!isListCompatible(exprTypeInfo.type))) 
				        semanticError(1, ERR_MUST_BE_LIST);
			        if ($<flag>3)  // ident already existed 
                    {
				        if (exprTypeInfo.isParam && !isIntCompatible($5.type))
				            semanticError(1, ERR_MUST_BE_INTEGER);
                        scopeStack.top().changeEntry(SYMBOL_TABLE_ENTRY(lexeme,
                            {$5.type, $5.numParams, $5.returnType, false, $5.value, $5.listValue}));
                    }
                    else 
			        {
                        // if ident didn't already exist, 
                        // just change the type
                        scopeStack.top().changeEntry(SYMBOL_TABLE_ENTRY(lexeme,
                            {$5.type, $5.numParams, $5.returnType, false,$5.value, $5.listValue}));
                    }
			        if (($2.type == INDEX_PROD) && ($5.type == LIST))
				        semanticError(1, ERR_CANNOT_BE_LIST);

                    if($2.type == INDEX_PROD)
                    {
                        list<TYPE>::iterator itr = exprTypeInfo.listValue->begin();
                        advance(itr, $2.value.intValue - 1);
                        (*itr) = $5.value;
                        
                        if($2.value.intValue > exprTypeInfo.listValue->size())
                        {
                            semanticError(0, ERR_SUB_OUT_OF_BOUNDS);
                        }
                        else if($2.value.intValue == -1)
                        {
                            semanticError(0, ERR_SUB_OUT_OF_BOUNDS);
                        }


                        cout << "( ";
                        for (list<TYPE>::iterator itr = exprTypeInfo.listValue->begin(), end = exprTypeInfo.listValue->end(); itr != end; ++itr) 
                        {
                            if(itr->type == INT)
                            {
                                cout << itr->intValue;
                            }
                            else if(itr->type == STR)
                            {
                                cout << itr->stringValue;
                            }
                            else if(itr->type == BOOL)
                            {
                                if(itr->boolValue)
                                {
                                    cout << "TRUE";
                                }
                                else
                                {
                                    cout << "FALSE";
                                }
                            }
                            else if(itr->type == FLOAT)
                            {
                                cout << fixed << setprecision(2)<< itr->floatValue;
                            }
                            cout << " ";
                        }
                        cout << ")";
                        $$.listValue = exprTypeInfo.listValue;
                        $$.type = LIST;

                    }
                    else
                    {
                        $$.type = $5.type;
                        $$.numParams = $5.numParams;
                        $$.returnType = $5.returnType;
                        $$.isParam = $5.isParam;
                        $$.value = $5.value;
                        $$.listValue = $5.listValue;
                    }
                    //{
                    //    cout << "do i " << endl;
                    //    list<TYPE>::const_iterator itr = exprTypeInfo.listValue->begin();
                    //    advance(itr, $2.value.intValue - 1);
                    //    (*itr) = $5.value;
                    //    $$.type = LIST;
                    //}

                    //for (list<TYPE>::const_iterator itr = $5.listValue->begin(), end = $5.listValue->end(); itr != end; ++itr) 
                    //{
                    //    $$.listValue->push_back(*itr);
                   // }
                   
                }
                ;

N_INDEX:        T_LBRACKET T_LBRACKET N_EXPR T_RBRACKET T_RBRACKET
			    {
                    printRule("INDEX", " [[ EXPR ]]");
                    $$.type = INDEX_PROD;
                    $$.value.intValue = $3.value.intValue;
			    }
			    | /* epsilon */
                {
                    printRule("INDEX", " epsilon");
			        $$.type = NOT_INDEX_PROD;
                }
                ;

N_QUIT_EXPR:    T_QUIT T_LPAREN T_RPAREN
                {
                    printRule("QUIT_EXPR", "QUIT()");
                    $$.type = NULL_TYPE;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                }
                ;

N_OUTPUT_EXPR:  T_PRINT T_LPAREN N_EXPR T_RPAREN
                {
                    printRule("OUTPUT_EXPR", "PRINT ( EXPR )");
                    if(($3.type == FUNCTION) || ($3.type == NULL_TYPE)) 
				        semanticError(1, ERR_CANNOT_BE_FUNCT_OR_NULL);
                    $$.type = $3.type;
                    $$.numParams = $3.numParams;
                    $$.returnType = $3.returnType;
                    $$.isParam = $3.isParam;
                    //cout << "where" << endl;
                    
                    //cout << "value type=" << $3.type;
                    
                    //cout << "output size = " << $3.listValue->size()<< endl;
                    if($3.type == INT)
                    {
                        cout << $3.value.intValue << endl;
                        $$.value.intValue = $3.value.intValue;
                        $$.type = INT;
                    }
                    else if($3.type == FLOAT)
                    {
                        $$.value.floatValue = $3.value.floatValue;
                        $$.type = FLOAT;
                        cout << $3.value.floatValue << endl;
                    }
                    else if($3.type == BOOL)
                    {
                        $$.value.boolValue = $3.value.boolValue;
                        $$.type = BOOL;
                        if($3.value.boolValue)
                        {
                            cout << "TRUE" << endl;
                        }
                        else
                        {
                            cout << "FALSE" << endl;
                        }
                    }
                    else if($3.type == STR)
                    {
                        cout << $3.value.stringValue << endl;
                        strcpy($$.value.stringValue, $3.value.stringValue);
                        $$.type = STR;
                    }
                    else
                    {
                        $$.listValue = $3.listValue;
                        $$.type = LIST;
                        cout << "( ";
                        for (list<TYPE>::const_iterator itr = $3.listValue->begin(), end = $3.listValue->end(); itr != end; ++itr) 
                        {
                            if(itr->type == INT)
                            {
                                cout << itr->intValue;
                            }
                            else if(itr->type == STR)
                            {
                                cout << itr->stringValue;
                            }
                            else if(itr->type == BOOL)
                            {
                                if(itr->boolValue)
                                {
                                    cout << "TRUE";
                                }
                                else
                                {
                                    cout << "FALSE";
                                }
                            }
                            else if(itr->type == FLOAT)
                            {
                                cout << fixed << setprecision(2)<< itr->floatValue;
                            }
                            cout << " ";
                        }
                        cout << ")" << endl;
                    }
                }
                | T_CAT T_LPAREN N_EXPR T_RPAREN
                {
                    printRule("OUTPUT_EXPR","CAT ( EXPR )");
                    if(($3.type == FUNCTION) || ($3.type == NULL_TYPE)) 
				        semanticError(1, ERR_CANNOT_BE_FUNCT_OR_NULL);
                    $$.type = NULL_TYPE;
                    $$.numParams = $3.numParams;
                    $$.returnType = $3.returnType;
                    $$.isParam = $3.isParam;
                    //cout << "where" << endl;
                    
                    //cout << "value type=" << $3.type;
                    
                    //cout << "output size = " << $3.listValue->size()<< endl;
                    if($3.type == INT)
                    {
                        cout << $3.value.intValue << endl;
                    }
                    else if($3.type == FLOAT)
                    {
                        cout << fixed << setprecision(2)<<$3.value.floatValue << endl;
                    }
                    else if($3.value.type == BOOL)
                    {
                        if($3.value.boolValue)
                        {
                            cout << "TRUE" << endl;
                        }
                        else
                        {
                            cout << "FALSE" << endl;
                        }
                    }
                    else if($3.type == STR)
                    {
                        cout << $3.value.stringValue << endl;
                    }
                    else//($3.value.type == LIST)
                    {
                        //cout << "output size = " << $3.listValue->size()<< endl;
                        cout << "( ";
                        for (list<TYPE>::const_iterator itr = $3.listValue->begin(), end = $3.listValue->end(); itr != end; ++itr) 
                        {
                            if(itr->type == INT)
                            {
                                cout << itr->intValue;
                            }
                            else if(itr->type == STR)
                            {
                                cout << itr->stringValue;
                            }
                            else if(itr->type == BOOL)
                            {
                                if(itr->boolValue)
                                {
                                    cout << "TRUE";
                                }
                                else
                                {
                                    cout << "FALSE";
                                }
                            }
                            else if(itr->type == FLOAT)
                            {
                                cout << fixed << setprecision(2)<< itr->floatValue;
                            }
                            cout << " ";
                        }
                        cout << ")" << endl;
                    }
                }
                ;

N_INPUT_EXPR:   T_READ T_LPAREN T_RPAREN
                {
                    printRule("INPUT_EXPR", "READ ( )");
                    $$.type = INT_OR_STR_OR_FLOAT;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    
                    
                    string in;
                    getline(cin, in);
                    //cout << "helo";
                    //cout <<"in="<< in <<endl;
                    //cout << "liem=" << in[0] <<endl;
                    
                    
                    
                    if(in[0] != '+' && in[0] != '-' && (!isdigit(in[0])))//!isdigit(in[0])) //|| in[0] != '+' || in[0] != '-')
                    {
                        $$.type = STR;
                        strcpy($$.value.stringValue, in.c_str());
                        //cout << "string" <<endl;
                    }
                    else if(in[2] == '.')
                    {
                        $$.type = FLOAT;
                        $$.value.floatValue = atof(in.c_str());
                        //cout<<"float" <<endl;
                    }
                    else
                    {
                        $$.type = INT;
                        $$.value.intValue = atoi(in.c_str());
                        //cout << "N_INTPUT_EXPR"<<$$.value.intValue << endl;
                    }

                }
                ;

N_FUNCTION_DEF: T_FUNCTION
                {
			    printRule("FUNCTION_DEF", "FUNCTION ( PARAM_LIST )" " COMPOUND_EXPR");
                beginScope();
                }
                T_LPAREN N_PARAM_LIST
  		        {
			        $<num>$ = scopeStack.top().getNumEntries();
   		        }
		        T_RPAREN N_COMPOUND_EXPR
                {
                    endScope();
                    if($7.type == FUNCTION) 
				        semanticError(2, ERR_CANNOT_BE_FUNCT);
                    $$.type = FUNCTION;
                    $$.numParams = $<num>5;
                    $$.returnType = $7.type;
                    $$.isParam = false;
                }
                ;

N_PARAM_LIST:   N_PARAMS
                {
                    printRule("PARAM_LIST", "PARAMS");
                }
                | N_NO_PARAMS
                {
                    printRule("PARAM_LIST", "NO PARAMS");
                }
                ;

N_NO_PARAMS:    /* epsilon */
                {
                    printRule("NO_PARAMS", "epsilon");
                }
                ;

N_PARAMS:       T_IDENT
                {
                    printRule("PARAMS", "IDENT");
                    string lexeme = string($1);
                    if(!suppressTokenOutput)
                        printf("___Adding %s to symbol table\n", $1);
                    // assuming params are ints
                    TYPE_INFO exprTypeInfo = {INT, NOT_APPLICABLE, NOT_APPLICABLE, true};
                    bool success = scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme, exprTypeInfo));
                    if(!success) 
				        semanticError(0, ERR_MULTIPLY_DEFINED_IDENT);
                }
                | T_IDENT T_COMMA N_PARAMS
                {
                    printRule("PARAMS", "IDENT, PARAMS");
                    string lexeme = string($1);
                    if(!suppressTokenOutput)
                        printf("___Adding %s to symbol table\n", $1);
                    // assuming params are ints 
                    TYPE_INFO exprTypeInfo = {INT, NOT_APPLICABLE, NOT_APPLICABLE, true};
                    bool success = scopeStack.top().addEntry(SYMBOL_TABLE_ENTRY(lexeme, exprTypeInfo));
                    if(!success) 
				        semanticError(0, ERR_MULTIPLY_DEFINED_IDENT);
                }
                ;

N_FUNCTION_CALL: T_IDENT T_LPAREN N_ARG_LIST T_RPAREN
                {
                    printRule("FUNCTION_CALL", "IDENT" " ( ARG_LIST )");
                    TYPE_INFO exprTypeInfo = findEntryInAnyScope(string($1));
                    if (exprTypeInfo.type == UNDEFINED) 
                      semanticError(0, ERR_UNDEFINED_IDENT);
                    if(exprTypeInfo.type != FUNCTION) 
				        semanticError(1, ERR_MUST_BE_FUNCT);
                    if($3 > exprTypeInfo.numParams) 
				        semanticError(0, ERR_TOO_MANY_PARAMS);
                    if($3 < exprTypeInfo.numParams) 
				        semanticError(0, ERR_TOO_FEW_PARAMS);
                    $$.type = exprTypeInfo.returnType;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                }
                ;

N_ARG_LIST:     N_ARGS
                {
                    printRule("ARG_LIST", "ARGS");
                    $$ = $1;
                    numExprs = 0;
                }
                | N_NO_ARGS
                {
                    printRule("ARG_LIST", "NO_ARGS");
                    numExprs = 0;
                    $$ = numExprs;
                }
                ;

N_NO_ARGS:      /* epsilon */
                {
                    printRule("NO_ARGS", "epsilon");
                }
                ;

N_ARGS:         N_EXPR
                {
                    printRule("ARGS", "EXPR");
                    numExprs++;
                    if(!isIntCompatible($1.type)) 
                        semanticError(0, ERR_NON_INT_FUNCT_PARAM);
			        $$ = numExprs;
                }
                | N_EXPR 
                {
                    printRule("ARGS", "EXPR, ARGS");
                    numExprs++;
                    if(!isIntCompatible($1.type)) 
				        semanticError(0, ERR_NON_INT_FUNCT_PARAM);
                }
			    T_COMMA N_ARGS
			    {
			        $$ = numExprs;
			    }
                ;

N_ARITHLOGIC_EXPR: N_SIMPLE_ARITHLOGIC
                {
                    printRule("ARITHLOGIC_EXPR", "SIMPLE_ARITHLOGIC");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    //cout << "arith_int=" << $1.value.intValue << endl;
                    //cout << "arith_bool=" << $1.value.boolValue << endl;
                }
                | N_SIMPLE_ARITHLOGIC N_REL_OP
                  N_SIMPLE_ARITHLOGIC
                {
                    printRule("ARITHLOGIC_EXPR", "SIMPLE_ARITHLOGIC REL_OP " "SIMPLE_ARITHLOGIC");
                    if(isInvalidOperandType($1.type))
                    	semanticError(1,ERR_MUST_BE_INT_FLOAT_OR_BOOL);
                    if(isInvalidOperandType($3.type)) 
                   	    semanticError(2, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
                    $$.type = BOOL; 
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    //cout << "**$1 = " <<$1.value.intValue << endl;
                    //cout << "**$3 = " << $3.value.intValue << endl;
                    //cout << "**$1type = " <<$1.value.type << endl;
                    //cout << "**$3type = " << $3.value.type << endl;


                    if($2 == LT)
                    {
                        //cout << "hello";
                        if(($1.value.type == INT) && ($3.value.type == BOOL))
                        {
                            $$.value.boolValue = ($1.value.intValue < $3.value.boolValue);
                        }
                        else if(($1.value.type == BOOL) && ($3.value.type == INT))
                        {
                            $$.value.boolValue = ($1.value.boolValue < $3.value.intValue);
                        }
                        else if(($1.value.type == BOOL) && ($3.value.type == BOOL))
                        {
                            $$.value.boolValue = ($1.value.boolValue < $3.value.boolValue);
                        }
                        else
                        {
                            $$.value.boolValue = ($1.value.intValue < $3.value.intValue);
                        }
                    }
                    else if($2 == GT)
                    {
                        //cout << "hello";
                        if(($1.value.type == INT) && ($3.value.type == BOOL))
                        {
                            $$.value.boolValue = ($1.value.intValue > $3.value.boolValue);
                        }
                        else if(($1.value.type == BOOL) && ($3.value.type == INT))
                        {
                            $$.value.boolValue = ($1.value.boolValue > $3.value.intValue);
                        }
                        else if(($1.value.type == BOOL) && ($3.value.type == BOOL))
                        {
                            $$.value.boolValue = ($1.value.boolValue > $3.value.boolValue);
                        }
                        else
                        {
                            $$.value.boolValue = ($1.value.intValue > $3.value.intValue);
                        }
                    }
                    else if($2 == EQ)
                    {   
                        if(($1.value.type == INT) && ($3.value.type == BOOL))
                        {
                            $$.value.boolValue = ($1.value.intValue == $3.value.boolValue);
                        }
                        else if(($1.value.type == BOOL) && ($3.value.type == INT))
                        {
                            $$.value.boolValue = ($1.value.boolValue == $3.value.intValue);
                        }
                        else
                        {
                            $$.value.boolValue = ($1.value.boolValue == $3.value.boolValue);
                        }
                    }
                   // cout << "**final = " << $$.value.boolValue << endl;

                }
                ;

N_SIMPLE_ARITHLOGIC: N_TERM N_ADD_OP_LIST
                {
                    printRule("SIMPLE_ARITHLOGIC", "TERM ADD_OP_LIST");
			        if ($2.type != NOT_APPLICABLE)
			        {
                        if(isInvalidOperandType($1.type))
                            semanticError(1, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
                        if(isInvalidOperandType($2.type))
                            semanticError(2, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
                        //cout << "**$1 = " <<$1.value.type << endl;
                        //cout << "**$2 = " << $2.value.type << endl;
                        //cout << "mayb";
                        if (isBoolCompatible($1.value.type) ||  isBoolCompatible($2.value.type))
				        {    
                            $$.type = BOOL;
                            $$.value.type = BOOL;
                            //cout << "eam i here="<<$$.value.boolValue << endl;
                            if($2.value.op == OR)
                            {
                                $$.value.boolValue = ($1.value.boolValue || $2.value.boolValue);
                            }
                            //cout << "**$1 = " <<$1.value.boolValue << endl;
                            //cout << "**$2 = " << $2.value.boolValue << endl;
                            else 
                            {
                                $$.value.boolValue = $1.value.boolValue;
                                
                            }
                            //if($2.value.op == AND)
                            //{
                            //    $$.value.boolValue = ($1.value.boolValue && $2.value.boolValue);
                           // }
                           //cout << "**$2 = " << $$.value.boolValue << endl;
                        }
				        else if (isIntCompatible($1.value.type) && isIntCompatible($2.value.type))
                        {
                            $$.type = INT;
                            $$.value.type = INT;
                            if($2.value.op == ADD)
                            {
                                $$.value.intValue = $1.value.intValue + $2.value.intValue;
                            }
                            if($2.value.op == SUB)
                            {
                                $$.value.intValue = $1.value.intValue - $2.value.intValue;
                            }

                        }
                        else if (isFloatCompatible($1.value.type) || isFloatCompatible($2.value.type))
				        {    
                            $$.type = FLOAT;
                            $$.value.type = FLOAT;
                            
                            if($2.value.op == ADD)
                            {
                                $$.value.floatValue = $1.value.floatValue + $2.value.floatValue
                                        + $1.value.intValue + $2.value.intValue;
                            }
                            if($2.value.op == SUB)
                            {
                                $$.value.floatValue = $1.value.floatValue - $2.value.floatValue
                                        - $1.value.intValue - $2.value.intValue;
                            }
                        }   

				        else 
                            $$.type = $1.type;
				            $$.numParams = NOT_APPLICABLE;
				            $$.returnType = NOT_APPLICABLE;
                     	    $$.isParam = false;
			        }
                    else 
			        {
				        $$.type = $1.type;
				        $$.numParams = $1.numParams;
				        $$.returnType = $1.returnType;
                    	$$.isParam = $1.isParam;
                        $$.value = $1.value;
                        $$.value.type = $1.type;
			        }

                
                }
                ;

N_ADD_OP_LIST:  N_ADD_OP N_TERM N_ADD_OP_LIST
                {
                    printRule("ADD_OP_LIST", "ADD_OP TERM ADD_OP_LIST");
			        int argWithErr = ($3.type == NOT_APPLICABLE)? 2: 1;
                    if(isInvalidOperandType($2.type))             
                        semanticError(argWithErr, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
			    
                    $$.numParams = NOT_APPLICABLE;
			        $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;

                    //cout << "**0" << endl;
                    //cout << $$.value.floatValue << endl;
                    //cout << $$.value.intValue << endl;
                    //cout << $$.value.boolValue << endl;

                    if($1 == OR)
                    {
				        $$.type = BOOL;
                        $$.value.op = $1;
                        $$.value.boolValue = $2.value.boolValue;
                    }
			        else
			        {
				        if($3.type == NOT_APPLICABLE)
				        {
                            $$.type = $2.type;
                            $$.value.op = $1;
                            $$.value.intValue = $2.value.intValue;
                            $$.value.floatValue = $2.value.floatValue;
                            $$.value.boolValue = $2.value.boolValue;
                            $$.value.type = $2.value.type;
                            strcpy($$.value.stringValue, $2.value.stringValue);
                            //cout << "**1" << endl;
                            //cout << $$.value.floatValue << endl;
                            //cout << $$.value.intValue << endl;
                            //cout << $$.value.boolValue << endl;
                        }
				        else
				        {
				            if (isIntCompatible($2.type) && isIntCompatible($3.type))
                            {   
                                $$.value.type = INT;
                                if($3.value.op == ADD)
                                {
                                    $$.value.op = ADD;
                                    $$.value.intValue = $3.value.intValue + $3.value.boolValue 
                                                        + $2.value.intValue + $2.value.boolValue;
                                }
                                else if($3.value.op == SUB)
                                {
                                    $$.value.op = SUB;
                                    $$.value.intValue = $3.value.intValue - $3.value.boolValue 
                                                    - $2.value.intValue - $2.value.boolValue;
                                }
                            }
                            else 
                            {
                                $$.value.type = FLOAT;
                                //cout << $$.value.intValue << endl;
                                //cout <<"type = " << $$.type << endl;
                                //cout << $1.value.op;
                                if($3.value.op == ADD)
                                {
                                    $$.value.op = ADD;
                                    $$.value.floatValue = $3.value.floatValue + $3.value.intValue + $3.value.boolValue 
                                        + $2.value.floatValue + $2.value.intValue + $2.value.boolValue;
                                }
                                else if($3.value.op == SUB)
                                {
                                    $$.value.op = SUB;
                                    $$.value.floatValue = $3.value.floatValue - $3.value.intValue - $3.value.boolValue 
                                        - $2.value.floatValue - $2.value.intValue - $2.value.boolValue;
                                }
                                //cout << $$.value.intValue;


                            }
				        }
                    }
                   // cout <<"endtype = " << $$.type << endl;

                }
                | /* epsilon */
                {
                    printRule("ADD_OP_LIST", "epsilon");
			        $$.type = NOT_APPLICABLE;
			        $$.numParams = NOT_APPLICABLE;
			        $$.returnType = NOT_APPLICABLE;
			        $$.isParam = false;
                }
                ;

N_TERM:         N_FACTOR N_MULT_OP_LIST
                {
                    printRule("TERM", "FACTOR MULT_OP_LIST");
			        if ($2.type != NOT_APPLICABLE)
			        {
				        if(isInvalidOperandType($1.type))
                            semanticError(1, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
                     	if(isInvalidOperandType($2.type))
                            semanticError(2, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
                     	
                         $$.numParams = NOT_APPLICABLE;
                     	$$.returnType = NOT_APPLICABLE;
                    	$$.isParam = false;
				        

                        //cout  <<"act1=" << $1.value.boolValue << endl;
                        //cout  <<"act2=" << $2.value.boolValue << endl;
                        //cout << ($1.value.boolValue && $2.value.boolValue);
                        if (isBoolCompatible($1.value.type) &&  isBoolCompatible($2.value.type))
                            {
                            if ($2.value.op == AND)
				            {
                                $$.type = BOOL;
                                $$.value.type = BOOL;
                                $$.value.boolValue = ($1.value.boolValue && $2.value.boolValue);
                            }

                        }
				        else
				        {
				            if (isIntCompatible($1.value.type) && isIntCompatible($2.value.type))
                            {
                                $$.type = INT;
                                if($2.value.op == MULT)
                                {
                                    $$.value.intValue = $1.value.intValue * $2.value.intValue;
                                }
                                else if($2.value.op == DIV)
                                {
                                    if($2.value.intValue == 0)
                                    {
                                        semanticError(0,ERR_ATTEMPTED_DIV_BY_ZERO);
                                    }
                                    else
                                        $$.value.intValue = $1.value.intValue / $2.value.intValue;
                                }
                                else if($2.value.op == MOD)
                                {
                                    $$.value.intValue = $1.value.intValue % $2.value.intValue;
                                }
                                else if($2.value.op == POW)
                                {
                                    $$.value.intValue = pow($1.value.intValue, $2.value.intValue);
                                }
                            }
                            else 
                            {
                                $$.type = FLOAT;
                                if($2.value.op == MULT)
                                {
                                    $$.value.floatValue = $1.value.floatValue * $2.value.floatValue;
                                }
                                else if($2.value.op == DIV)
                                {
                                    if($2.value.type == INT)
                                        if($2.value.intValue == 0)
                                        {
                                            semanticError(0,ERR_ATTEMPTED_DIV_BY_ZERO);
                                        }
                                        else
                                            $$.value.floatValue = $1.value.floatValue / $2.value.intValue;
                                    else if ($2.value.type == BOOL)
                                        if($2.value.boolValue == 0)
                                        {
                                            semanticError(0,ERR_ATTEMPTED_DIV_BY_ZERO);
                                        }
                                        else
                                            $$.value.floatValue = $1.value.floatValue / $2.value.boolValue;
                                    else
                                    {
                                        if($2.value.floatValue == 0)
                                        {
                                            semanticError(0,ERR_ATTEMPTED_DIV_BY_ZERO);
                                        }
                                        $$.value.floatValue = $1.value.floatValue / $2.value.floatValue;
                                    }
                                }
                                else if($2.value.op == MOD)
                                {
                                    $$.value.floatValue = fmod($1.value.floatValue, $2.value.floatValue);
                                }
                                else if($2.value.op == POW)
                                {
                                    if($2.value.type == INT)
                                        $$.value.floatValue = pow($1.value.floatValue , $2.value.intValue);
                                    else if ($2.value.type == BOOL)
                                        $$.value.floatValue = pow($1.value.floatValue, $2.value.boolValue);
                                    else
                                        $$.value.floatValue = pow($1.value.floatValue, $2.value.floatValue);
                                }
                            }
				        }
			        }
                    else 
			        {
				        $$.type = $1.type;
				        $$.numParams = $1.numParams;
				        $$.returnType = $1.returnType;
				        $$.isParam = $1.isParam;
                        $$.value = $1.value;
			        }
                }
                ;

N_MULT_OP_LIST: N_MULT_OP N_FACTOR N_MULT_OP_LIST
                {
                    printRule("MULT_OP_LIST", "MULT_OP FACTOR MULT_OP_LIST");
			        int argWithErr = ($3.type == NOT_APPLICABLE)? 2: 1;
                    if(isInvalidOperandType($2.type))                    				
                        semanticError(argWithErr, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
			        $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
			        $$.isParam = false;
			        
                    //if($1 == AND)
                    //{
                    //    $$.type = BOOL;
                    //    $$.value.type = BOOL;
                    //    $$.value.op = AND;
                    //    $$.value.boolValue = $2.value.boolValue;
                     //   $$.value.intValue = $2.value.intValue;
                    //    $$.value.floatValue = $2.value.floatValue;
                    //}
                    //else
                    //{
                        if($3.type == NOT_APPLICABLE)
				        {
                            $$.type = $2.type;
                            $$.value.op = $1;
                            $$.value.intValue = $2.value.intValue;
                            $$.value.floatValue = $2.value.floatValue;
                            $$.value.boolValue = $2.value.boolValue;
                            $$.value.type = $2.value.type;
                            strcpy($$.value.stringValue, $2.value.stringValue);
                        }
			            else
			            {
                            if(isInvalidOperandType($3.type))                    				  
                                semanticError(argWithErr, ERR_MUST_BE_INT_FLOAT_OR_BOOL);
				            if (isIntCompatible($2.type) && isIntCompatible($3.type))
                            {
				                $$.type = INT;
                            }
				            else 
                            {
                                $$.type = FLOAT;
                            }
			            }
                    //}
                }
                
                | /* epsilon */
                {
                    printRule("MULT_OP_LIST", "epsilon");
			        $$.type = NOT_APPLICABLE;
			        $$.numParams = NOT_APPLICABLE;
			        $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                }
                ;

N_FACTOR:       N_VAR
                {
                    printRule("FACTOR", "VAR");
                    $$.type = $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;

                }
                | N_CONST
                {
                    printRule("FACTOR", "CONST");
                    $$.type = $1.type;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;
                    $$.value = $1.value;
                    $$.value.type = $1.value.type;
                    //cout << "**=" << $1.value.boolValue<<endl;

                }
                | T_LPAREN N_EXPR T_RPAREN
                {
                    printRule("FACTOR", "( EXPR )");
                    $$.type = $2.type;
                    $$.numParams = $2.numParams;
                    $$.returnType = $2.returnType;
                    $$.isParam = $2.isParam;
                    $$.value = $2.value;
                }
                | T_NOT N_FACTOR
                {
                    printRule("FACTOR", "! FACTOR");
                    $$.type = BOOL;
                    $$.numParams = $2.numParams;
                    $$.returnType = $2.returnType;
                    $$.isParam = $2.isParam;
                    $$.value.type = BOOL;

                    if($2.value.boolValue || $2.value.intValue || $2.value.floatValue)
                    {
                        $$.value.boolValue = 0;
                    }
                    else
                    {
                        $$.value.boolValue = 1;
                    }
                    
                }
                ;

N_ADD_OP:       T_ADD
                {
                    printRule("ADD_OP", "+");
                    $$ = ADD;
                
                }
                | T_SUB
                {
                    printRule("ADD_OP", "-");
                    $$ = SUB;
                }
                | T_OR
                {
                    printRule("ADD_OP", "|");
                    $$ = OR;
                }
                ;

N_MULT_OP:      T_MULT
                {
                    printRule("MULT_OP", "*");
                    $$ = MULT;
                }
                | T_DIV
                {
                    printRule("MULT_OP", "/");
                    $$ = DIV;
                }
                | T_AND
                {
                    printRule("MULT_OP", "&");
                    $$ = AND;
                }
                | T_MOD
                {
                    printRule("MULT_OP", "\%\%");
                    $$ = MOD;
                }
                | T_POW
                {
                    printRule("MULT_OP", "^");
                    $$ = POW;
                }
                ;

N_REL_OP:       T_LT
                {
                    printRule("REL_OP", "<");
                    $$ = LT;
                }
                | T_GT
                {
                    printRule("REL_OP", ">");
                    $$ = GT;
                }
                | T_LE
                {
                    printRule("REL_OP", "<=");
                    $$ = LE;
                }
                | T_GE
                {
                    printRule("REL_OP", ">=");
                    $$ = GE;
                }
                | T_EQ
                {
                    printRule("REL_OP", "==");
                    $$ = EQ;
                }
                | T_NE
                {
                    printRule("REL_OP", "!=");
                    $$ = NE;
                }
                ;

N_VAR:          N_ENTIRE_VAR
                {
                    printRule("VAR", "ENTIRE_VAR");
                    $$.type == $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                | N_SINGLE_ELEMENT
                {
                    printRule("VAR", "SINGLE_ELEMENT");
                    $$.type == $1.type;
                    $$.numParams = $1.numParams;
                    $$.returnType = $1.returnType;
                    $$.isParam = $1.isParam;
                    $$.value = $1.value;
                    $$.listValue = $1.listValue;
                }
                ;

N_SINGLE_ELEMENT: T_IDENT T_LBRACKET T_LBRACKET N_EXPR
                   T_RBRACKET T_RBRACKET
                {
                    printRule("SINGLE_ELEMENT", "IDENT"
                              " [[ EXPR ]]");
                    TYPE_INFO exprTypeInfo = findEntryInAnyScope($1);
                    if(exprTypeInfo.type == UNDEFINED) 
				        semanticError(0, ERR_UNDEFINED_IDENT);
                    if(!isListCompatible(exprTypeInfo.type)) 
				        semanticError(1, ERR_MUST_BE_LIST);  
                    
                    //$$.type = INT_OR_STR_OR_FLOAT_OR_BOOL;
                    $$.numParams = NOT_APPLICABLE;
                    $$.returnType = NOT_APPLICABLE;
                    $$.isParam = false;

                    //for (list<TYPE>::const_iterator itr = $1.listValue->begin(), end = $4.value.intValue; itr == end; ++itr) 
                    //{
                        //$$.listValue->push_back(*itr);
                        //cout << itr.value.intValue;
                    //}
                    
                    list<TYPE>::const_iterator itr = exprTypeInfo.listValue->begin();
                    advance(itr, $4.value.intValue - 1);

                    if($4.value.intValue == 0)
                    {
                        semanticError(0, ERR_SUB_OUT_OF_BOUNDS);
                    }
                    if($4.value.intValue > exprTypeInfo.listValue->size())
                    {
                        semanticError(0, ERR_SUB_OUT_OF_BOUNDS);
                    }


                    //cout <<"index value ="<< (*itr).type << endl;
                    //cout << itr->floatValue<< endl;
                    
                    if(itr->type == INT)
                    {
                        $$.type = INT;
                        $$.value = *itr;
                    }
                    else if(itr->type == STR)
                    {
                        $$.type = STR;
                        cout << itr->stringValue;
                    }
                    else if(itr->type == BOOL)
                    {
                        $$.type = BOOL;
                        $$.value = *itr;
                    }
                    else if(itr->type == FLOAT)
                    {
                        $$.type = FLOAT;
                        $$.value.floatValue = (*itr).floatValue;
                    }

                    //cout<< "endhere =" << $$.value.floatValue<<endl;

                    //exprTypeInfo.lsitVal
                }
                ;

N_ENTIRE_VAR:   T_IDENT
                {
                    printRule("ENTIRE_VAR", "IDENT");
                    TYPE_INFO exprTypeInfo = findEntryInAnyScope(string($1));
                    if(exprTypeInfo.type == UNDEFINED)
                      semanticError(0, ERR_UNDEFINED_IDENT);
                    
                    $$.type = exprTypeInfo.type;
                    $$.numParams = exprTypeInfo.numParams;
                    $$.returnType = exprTypeInfo.returnType;
                    $$.isParam = exprTypeInfo.isParam;
                }
                ;

%%

#include "lex.yy.c"
extern FILE *yyin;

//  Construct a string as an argument number (argNum, 0
//  if no argument number in message) and message (errNum is
//  index position in ERR_MSG[]). Then call yyerror with that
//  string.
void semanticError(const int argNum, const int errNum)
{
  string errorMsg;
  int errNo = errNum;

  if ((errNum < 0) || (errNum > NUM_ERR_MESSAGES-1))
    errNo = ERR_ERROR;
  if (argNum > 0)
    errorMsg = "Arg " + to_string(argNum) + " ";
  else errorMsg = "";
  errorMsg += ERR_MSG[errNo];
  yyerror(errorMsg.c_str());
}

// Output type and lexeme.
void printTokenInfo(const char* token_type, const char* lexeme)
{
  if(!suppressTokenOutput) 
  {
    printf("TOKEN: %s \t\t LEXEME: %s\n", token_type, lexeme);
  }
}

// Output production info as nonterm on left-hand side (1st
// param) and symbols on right-hand side (2nd param).
void printRule(const char *lhs, const char *rhs)
{
  if(!suppressTokenOutput) 
  {
    printf("%s -> %s\n", lhs, rhs);
  }
  return;
}

// Determine whether given type is compatible with INT, FLOAT,
// or BOOL.
bool isIntOrFloatOrBoolCompatible(const int theType)
{
    return(isIntCompatible(theType) ||
           isFloatCompatible(theType) ||
		isBoolCompatible(theType)); 
}

// Determine whether given type is compatible with INT.
bool isIntCompatible(const int theType)
{
    return(isBoolCompatible(theType) ||
           ((theType & INT) == INT));
}

// Determine whether given type is compatible with BOOL.
bool isBoolCompatible(const int theType)
{
    return((theType & BOOL) == BOOL);
}

// Determine whether given type is compatible with FLOAT.
bool isFloatCompatible(const int theType)
{
    return((theType & FLOAT) == FLOAT);
}

// Determine whether given type is compatible with LIST.
bool isListCompatible(const int theType)
{
    return((theType & LIST) == LIST);
}

// Determine whether given type is considered an invalid
// operand type.
bool isInvalidOperandType(const int theType)
{
    return((theType == FUNCTION) ||
		(theType == NULL_TYPE) ||
		(theType == LIST) ||
		(theType == STR));
}

// Push a new SYMBOL_TABLE onto scopeStack.
void beginScope() 
{
    scopeStack.push(SYMBOL_TABLE());
    if(!suppressTokenOutput)
        printf("\n___Entering new scope...\n\n");
}

// Pop a SYMBOL_TABLE from scopeStack.
void endScope() 
{
    scopeStack.pop();
    if(!suppressTokenOutput)
        printf("\n___Exiting scope...\n\n");
}

// Pop all SYMBOL_TABLE's from scopeStack.
void cleanUp() 
{
    if (scopeStack.empty())
        return;
    else {
        scopeStack.pop();
        cleanUp();
    }
}

// If the_name exists in any SYMBOL_TABLE in scopeStack, return
// its TYPE_INFO; otherwise, return a TYPE_INFO that contains
// type UNDEFINED.
TYPE_INFO findEntryInAnyScope(const string the_name) 
{
    TYPE_INFO info = {UNDEFINED, NOT_APPLICABLE, NOT_APPLICABLE};
    if (scopeStack.empty()) 
        return(info);
    
    info = scopeStack.top().findEntry(the_name);
    
    if (info.type != UNDEFINED) 
        return(info);
    else 
    {   // check in "next higher" scope
        SYMBOL_TABLE symbolTable = scopeStack.top();
        scopeStack.pop();
        info = findEntryInAnyScope(the_name);
        scopeStack.push(symbolTable); // restore the stack
        return(info);
    }
}


int main(int argc, char** argv) 
{
    beginScope();
    if (argc < 2) 
    {
        printf("You must specify a file in the command line!\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");
    do 
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}