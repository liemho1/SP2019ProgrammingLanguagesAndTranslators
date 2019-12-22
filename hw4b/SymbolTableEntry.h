#ifndef SYMBOL_TABLE_ENTRY_H
#define SYMBOL_TABLE_ENTRY_H

#include <string>
using namespace std;


// type code declarations
#define UNDEFINED  -1
#define NULL_TYPE   0
#define INT         2
#define STR         4
#define BOOL        8
#define FLOAT       16
#define LIST        32
#define FUNCTION    64
#define INT_OR_STR_OR_FLOAT_OR_BOOL     30

#define INT_OR_STR_OR_FLOAT   22
#define INT_OR_STR 6
#define INT_OR_BOOL 10
#define INT_OR_FLOAT 18
#define INT_OR_LIST 34
#define STR_OR_BOOL 12
#define STR_OR_FLOAT 20
#define STR_OR_LIST 36
#define BOOL_OR_FLOAT 24
#define BOOL_OR_LIST 40
#define FLOAT_OR_LIST 48
#define INT_OR_STR_OR_FLOAT_OR_LIST 54



#define NOT_APPLICABLE  -1

typedef struct {
  int type;         // one of the above type codes
  int numParams;    // # of parameters if function type
  int returnType;   // return type if function
  bool isParam;     //check to see if ident is a parameter
} TYPE_INFO;

class SYMBOL_TABLE_ENTRY
{
private:
  // Member variables
  string name;
  TYPE_INFO typeInfo;

public:
  // Constructors
  SYMBOL_TABLE_ENTRY( ) {
    name = "";
    typeInfo.type = UNDEFINED;
    typeInfo.numParams = UNDEFINED;
    typeInfo.returnType = UNDEFINED;
    typeInfo.isParam = false;
  }

  SYMBOL_TABLE_ENTRY(const string theName, 
                     const TYPE_INFO theType)
  {
    name = theName;
    typeInfo.type = theType.type;
    typeInfo.numParams = theType.numParams;
    typeInfo.returnType = theType.returnType;
    typeInfo.isParam = theType.isParam;
  }

  // Accessors
  string getName() const { return name; }
  TYPE_INFO getTypeInfo() const { return typeInfo; }

};

#endif  // SYMBOL_TABLE_ENTRY_H
