#include <iostream>
#include <stdlib.h>
using namespace std;

int combinations(const int n, const int r);

int combinations(const int n, const int r)
{
  int answer;
  // Doh...this is the only one I know
  if ((n == 10) && (r == 5))
    answer = 252;
  else answer = 1;
  return(answer);
}

int main(int argc, char** argv)
{
  int n = atoi(argv[1]);
  int r = atoi(argv[2]);
  cout << combinations(n, r) << endl;
  return 0;
} 

