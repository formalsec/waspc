__attribute__((import_module("db"), import_name("get"))) int get();
__attribute__((import_module("db"), import_name("set"))) void set(int);

void incr() {
  int count = get();
  set(count + 1);
}

int main() {
  incr();
  return 0;
}
