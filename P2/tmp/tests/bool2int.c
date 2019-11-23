// Test conversion bool a int
{
  int i = true;
  bool b = 0;
  i = 5 * true;
  i = true + 5;
  i = i + 5;
  int  c[20];
  c[1] = true;
  struct { int  d1; bool d2; } d;
  d.d1 = true;
  d.d2 = 0;
}
