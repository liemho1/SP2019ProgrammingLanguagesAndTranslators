/*    example.l
 
 	Example of a lex specification file.
     
      To create the lexical analyzer:

      flex example.l
      g++ lex.yy.c -o lexer
      lexer < inputFileName
*/

%{
/* 
Definitions of constants, variables, & function prototypes go here 
*/

#define T_IDENT     	1
#define T_INTCONST  	2
#define T_UNKNOWN   	3
#define T_FOO       	4
#define T_OR 			5
#define T_STRCONST		6
#define T_SEMICOLON 	7
#define T_WHILE 		8
#define T_TRUE			9
#define T_POWER			10
#define T_MULT			11
#define T_PRINT			12
#define T_IF			13
#define T_ELSE			14
#define T_FLOATCONST 	15
#define T_GE			16
#define T_DIV			17
#define T_EQ			18
#define T_FALSE			19
#define T_RPAREN		20
#define T_RBRACKET		21
#define T_AND			22
#define T_LIST			23
#define T_LPAREN		24
#define T_COMMA			25
#define T_LBRACE		26
#define T_GT			27
#define T_ADD			28
#define T_RBRACE		29
#define T_IN			30
#define T_NEXT			31
#define T_LT			32
#define T_NE			33
#define T_SUB			34
#define T_FOR			35
#define T_BREAK			36
#define T_FUNCTION		37
#define T_ASSIGN		38
#define T_NOT 			39
#define T_CAT			40
#define T_READ			41
#define T_MOD			42
#define T_LE			43
#define T_LBRACKET		44
#define T_QUIT			45

int numLines = 0;

void printTokenInfo(const char* tokenType, char* lexeme);

%}
/* Defintions of regular expressions go here */

WSPACE			[ \t\v\r]+
NEWLINE         \n
COMMENT			#.*$

DIGIT	        [0-9]
LETTER          [a-zA-Z]

IDENT			{LETTER}*(\_)?({LETTER}|{DIGIT})*(\_)?({LETTER}|{DIGIT})* 
INTCONST        (\+|-)?{DIGIT}+
FLOATCONST		(\+|-)?{DIGIT}*?(\.){DIGIT}+

STRCONST 		\"[A-Za-z0-9 ]*\"

%%
"|"			{
				printTokenInfo("OR", yytext);
				return T_OR;
			}

";"			{
				printTokenInfo("SEMICOLON", yytext);
				return T_SEMICOLON;
			}

"while"		{
				printTokenInfo("WHILE", yytext);
				return T_WHILE;
			}

"TRUE"		{
				printTokenInfo("TRUE", yytext);
				return T_TRUE;
			}

"^"			{
				printTokenInfo("POWER", yytext);
				return T_POWER;
			}

"*"		{
				printTokenInfo("MULT", yytext);
				return T_MULT;
			}

"print"		{
				printTokenInfo("PRINT", yytext);
				return T_PRINT;
			}

"if"		{
				printTokenInfo("IF", yytext);
				return T_IF;
			}

"else"		{
				printTokenInfo("ELSE", yytext);
				return T_ELSE;
			}

">="		{
				printTokenInfo("GE", yytext);
				return T_GE;
			}

"/"			{
				printTokenInfo("DIV", yytext);
				return T_DIV;
			}

"=="		{
				printTokenInfo("EQ", yytext);
				return T_EQ;
			}

"FALSE"		{
				printTokenInfo("FALSE", yytext);
				return T_FALSE;
			}

")"			{
				printTokenInfo("RPAREN", yytext);
				return T_RPAREN;
			}

"]"			{
				printTokenInfo("RBRACKET", yytext);
				return T_RBRACKET;
			}

"&"			{
				printTokenInfo("AND", yytext);
				return T_AND;
			}

"list"		{
				printTokenInfo("LIST", yytext);
				return T_LIST;
			}

"("			{
				printTokenInfo("LPAREN", yytext);
				return T_LPAREN;
			}

","			{
				printTokenInfo("COMMA", yytext);
				return T_COMMA;
			}

"{"			{
				printTokenInfo("LBRACE", yytext);
				return T_LBRACE;
			}

">"			{
				printTokenInfo("GT", yytext);
				return T_GT;
			}

"+"			{
				printTokenInfo("ADD", yytext);
				return T_ADD;
			}
		
"}"			{
				printTokenInfo("RBRACE", yytext);
				return T_RBRACE;
			}

"in"		{
				printTokenInfo("IN", yytext);
				return T_IN;
			}

"next"		{
				printTokenInfo("NEXT", yytext);
				return T_NEXT;
			}

"<"			{
				printTokenInfo("LT", yytext);
				return T_LT;
			}

"!="		{
				printTokenInfo("NE", yytext);
				return T_NE;
			}

"-"			{
				printTokenInfo("SUB", yytext);
				return T_SUB;
			}

"for"		{
				printTokenInfo("FOR", yytext);
				return T_FOR;
			}

"break"		{
				printTokenInfo("BREAK", yytext);
				return T_BREAK;
			}

"function"	{
				printTokenInfo("FUNCTION", yytext);
				return T_FUNCTION;
			}

"="			{
				printTokenInfo("ASSIGN", yytext);
				return T_ASSIGN;
			}

"!"			{
				printTokenInfo("NOT", yytext);
				return T_NOT;
			}

"cat"		{
				printTokenInfo("CAT", yytext);
				return T_CAT;
			}

"read"		{
				printTokenInfo("READ", yytext);
				return T_READ;
			}

"%%"		{
				printTokenInfo("MOD", yytext);
				return T_MOD;
			}

"<="		{
				printTokenInfo("LE", yytext);
				return T_LE;
			}

"["			{
				printTokenInfo("LBRACKET", yytext);
				return T_LBRACKET;
			}

"quit"		{
				printTokenInfo("QUIT", yytext);
				return T_QUIT;
			}

{INTCONST}	{
				printTokenInfo("INTCONST", yytext);
				return T_INTCONST;
			}

{FLOATCONST} {
				printTokenInfo("FLOATCONST", yytext);
				return T_FLOATCONST;
			}

{IDENT}		{
				printTokenInfo("IDENT", yytext);
				return T_IDENT;
			}

{STRCONST}	{
				printTokenInfo("STRCONST", yytext);
				return T_STRCONST;
			}

{NEWLINE}	{
                numLines++;
            }

{COMMENT}	{
			}

{WSPACE}	{ 
			}
			
.			{
				printTokenInfo("UNKNOWN", yytext);
				return T_UNKNOWN;
			}
%%

// User-written code goes here

void printTokenInfo(const char* tokenType, char* lexeme) 
{
  printf("TOKEN: %s \t\t LEXEME: %s\n", tokenType, lexeme);
}

// You should supply a yywrap function.

// Having it return 1 means only 1 input file will be scanned.
int yywrap(void) { return 1; }

int main(void) 
{
  while ( yylex() ) ;  // Keep processing tokens until 0 returned

  return 0;
}


