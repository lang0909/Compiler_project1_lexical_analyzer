%{
extern int id_counter;
extern int string_counter;
extern char * yytext;
extern int yyleng;
#define INT 1
#define DOUBLE 2
#define STR 3
#define IF 4
#define WHILE 5
#define RETURN 6
#define ID 7
#define INTEGER 8
#define DOUBLE_NUM 9
#define STRING 10
#define OPERATORS 11
#define QUOTE 12
#define COMMA 13
#define LPAREN 14
#define RPAREN 15
#define SEMI 16
#define LBRACE 17
#define RBRACE 18
#define COMMENT 19
#define ERROR 20
%}
blank [ \t\n]+
digit [0-9]
letter [A-Za-z]
%%
{blank} ;
"if" {return IF;}
"int" {return INT;}
"double" {return DOUBLE;}
"str" {return STR;}
"while" {return WHILE;}
"return" {return RETURN;}
(_+)(_*({digit}|{letter})|({digit}|{letter})_*)+|{letter}({digit}|{letter}|_)* {++id_counter; return ID;}
0|[1-9]{digit}* {return INTEGER;}
{digit}+(\.{digit}+)?(("E"|"e")("+"|"-")?{digit}+)? {return DOUBLE_NUM;}
\"([^\"\n]|\\\n|\\\"([^\n]|\\\n)*\\\")*\" {++string_counter; return STRING;}
"+"|"-"|"*"|"/"|"="|">"|">="|"<"|"<="|"=="|"!=" {return OPERATORS;}
"\"" {return QUOTE;}
"," {return COMMA;}
"(" {return LPAREN;}
")" {return RPAREN;}
";" {return SEMI;}
"{" {return LBRACE;}
"}" {return RBRACE;}
\/\*([^*]|\*+[^*/])*\*+\/|"//".*  {return COMMENT;}
. {return ERROR;}
%%
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
struct symbol_table
{
    int symbol_index;
    char id[17];
    struct symbol_table * symbol_next;
};

struct string_table
{
    int string_index;
    char * string;
    struct string_table * string_next;
};

int id_counter=0;
int string_counter=0;
extern FILE *yyin;
extern char *yytext;
extern int yyleng;
void add_symbol(struct symbol_table ** first_address,char *symbol,int ** id_count)
{
    struct symbol_table * new = (struct symbol_table*)malloc(sizeof(struct symbol_table));
    strcpy(new->id,symbol);
    new->symbol_index = **id_count;
    *first_address = new;
}

int symbol_index(struct symbol_table * first,char *symbol,int * id_count)
{
    struct symbol_table * s_next;
    s_next = first->symbol_next;
    while(s_next!=NULL)
    {
	if(strcmp(symbol,s_next->id)==0)
	{
	    *id_count = *id_count-1;
	    return s_next->symbol_index;
	}
	s_next = s_next->symbol_next;
    }
    add_symbol(&s_next,symbol,&id_count);
    while(first->symbol_next!=NULL)
    {
	first = first->symbol_next;
    }
    first->symbol_next = s_next;

    return *id_count;
}

void add_string(struct string_table ** h1_address,char*string1,int **string_count)
{
    struct string_table * new1 = (struct string_table*)malloc(sizeof(struct string_table));
    new1 -> string =(char*)malloc(strlen(string1));
    strcpy(new1->string,string1);
    new1->string_index = **string_count;
    *h1_address = new1;
}

int string_index(struct string_table * h1,char*string1,int *string_count)
{
    struct string_table * st_next;
    st_next = h1 -> string_next;
    while(st_next!=NULL)
    {
	if(strcmp(string1,st_next->string)==0)
	{
	    *string_count = *string_count-1;
	    return st_next->string_index;
	}
	st_next = st_next->string_next;
    }
    add_string(&st_next,string1,&string_count);
    while(h1->string_next!=NULL)
    {
	h1=h1->string_next;
    }
    h1->string_next = st_next;
    return *string_count;
}

int OP_DECIDE(char * a)
{
    if(strcmp(a,"+")==0)
	return 1;
    else if(strcmp(a,"-")==0)
	return 2;
    else if(strcmp(a,"*")==0)
	return 3;
    else if(strcmp(a,"/")==0)
	return 4;
    else if(strcmp(a,"=")==0)
	return 5;
    else if(strcmp(a,">")==0)
	return 6;
    else if(strcmp(a,">=")==0)
	return 7;
    else if(strcmp(a,"<")==0)
	return 8;
    else if(strcmp(a,"<=")==0)
	return 9;
    else if(strcmp(a,"==")==0)
	return 10;
    else if(strcmp(a,"!=")==0)
	return 11;
}

char* integer_convert(int i_len,char *b,char * it_temp)
{
    if(strncmp(b,"-",1)==0)
    {
	if(i_len<=11)
	    return b;
	else
	{
	    strncpy(it_temp,"-",1);
	    strcpy(it_temp+1,b+(i_len-10));
	    return it_temp;
	}
    }
    else
    {
	if(i_len<=10)
	    return b;
	else
	{
	    strcpy(it_temp,b+(i_len-10));
	    return it_temp;
	}
    }
}

char* id_convert(int id_len,char * c,char *id_temp)
{
    if(id_len<=16)
	return c;
    else
    {
	strncpy(id_temp,c,16);
	return id_temp;
    }
}

int main(int argc, char*argv[])
{
    char * s1[20]={"INT","DOUBLE","STR","IF","WHILE","RETURN","ID","INTEGER","DOUBLE_NUM","STRING","OPERATORS","QUOTE","COMMA","LPAREN","RPAREN","SEMI","LBRACE","RBRACE","COMMENT","ERROR"};
    char * s2[11]={"PLUS","MINUS","MULTI","DIVIDE","EQ","GT","GE","LT","LE","EEQ","NEQ"};
    struct symbol_table * symbol_head=(struct symbol_table*)malloc(sizeof(struct symbol_table));
    struct string_table * string_head=(struct string_table*)malloc(sizeof(struct string_table));
    symbol_head->symbol_index = 0;
    symbol_head->symbol_next = NULL;
    if(argc>1)
    {
	FILE * file;
	file = fopen(argv[1],"r");
	if(!file)
	{
	    fprintf(stderr,"could not open %s\n",argv[1]);
	    exit(1);
	}
	yyin=file;
	printf("TOKEN          LEXEME\n");
	int tok;
	char * it_temp;
	char * id_temp;
	while((tok=yylex())!=0)
	{
	    it_temp =(char*)malloc(12);
	    id_temp =(char*)malloc(20);
	    if(tok==7)
	    {
		printf("<%s, %d>     %s\n",s1[tok-1],symbol_index(symbol_head,id_convert(yyleng,yytext,id_temp),&id_counter),id_convert(yyleng,yytext,id_temp));
	    }
	    else if(tok==8)
	    {
		printf("<%s, %s>     %s\n",s1[tok-1],integer_convert(yyleng,yytext,it_temp),integer_convert(yyleng,yytext,it_temp));
	    }
	    else if(tok==9)
	    {
		printf("<%s, %f>   %s\n",s1[tok-1],atof(yytext),yytext);
	    }
	    else if(tok==10)
	    {
		printf("<%s, %d>    %s\n",s1[tok-1],string_index(string_head,yytext,&string_counter),yytext);
	    }
	    else if(tok==11)
	    {		
		printf("<%s, %s>    %s\n",s1[tok-1],s2[OP_DECIDE(yytext)-1],yytext);
	    }
	    else
	    {
		printf("<%s, >      %s\n",s1[tok-1],yytext);
	    }
	    free(it_temp);
	    free(id_temp);
	}
	fclose(yyin);
    }
    struct symbol_table *x;
    x = symbol_head->symbol_next;
    printf("=========symbol table===========\n");
    printf("index  symbols\n");
    while(x!=NULL)
    {
	struct symbol_table * temp;
	printf("  %d     %s\n",x->symbol_index,x->id);
	temp = x;
	x = x->symbol_next;
	free(temp);
    }
    struct string_table *y;
    y = string_head->string_next;
    printf("===========string table============\n");
    printf("index  strings\n");
    while(y!=NULL)
    {
	struct string_table *temp1;
	printf(" %d	%s\n",y->string_index,y->string);
	temp1 = y;
	y=y->string_next;
	free(temp1->string);
	free(temp1);
    }
    free(symbol_head);
    free(string_head);
}
