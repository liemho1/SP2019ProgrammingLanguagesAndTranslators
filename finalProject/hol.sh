#!/bin/sh


gsed -i '/^#include/a #include <stdlib.h>' *.cpp
gsed -i 's/int main()/int main(int argc, char** argv)/g' *.cpp

sed -i '/int main/,/cin>>/s/cin>>/\/\/cin>>1' *.cpp
sed -i '/\/\/cin>>/i\\ n = atoi(argv[1]);' *.cpp
