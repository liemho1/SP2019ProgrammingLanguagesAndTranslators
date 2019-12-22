#include <iostream>
#include <stdlib.h>
using namespace std;

int factorial(const int n);
float combinations(const int n, const int r);

int factorial(const int n)
{
  if (n == 1)
    return(1);
  else return(n * factorial(n-1));
}

float combinations(const int n, const int r)
{
  // Umm...I always get the formulas for combinations and
  // permutations confused...
  return(static_cast<float>(factorial(n)) / 
         factorial(n-r));
}

int main(int argc, char** argv)
{
  int n = atoi(argv[1]);
  int r = atoi(argv[2]);
  cout << combinations(n, r) << endl;
  return 0;
} 

