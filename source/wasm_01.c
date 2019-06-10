extern unsigned char __heap_base;
unsigned int g_bump_pointer = &__heap_base;

void *malloc(int n) {
  {
    unsigned int r = g_bump_pointer;
    bump_pointer = (bump_pointer + n);
    return ((void *)(r));
  }
}
int foo(int a, int b) { return (b + (2 * a * a)); }
int sum(int *a, int len) {
  {
    int sum = 0;
    for (int i = 0; (i < len); i += 1) {
      sum = (sum + a[i]);
    }
    return sum;
  }
}