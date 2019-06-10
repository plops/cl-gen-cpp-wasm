extern unsigned char __heap_base;
unsigned int g_bump_pointer = &__heap_base;

void *malloc(int n) {
  {
    unsigned int r = g_bump_pointer;
    bump_pointer = (bump_pointer + n);
    return ((void *)(r));
  }
}
int foo(int a, int b) { return (b + (a * a)); }