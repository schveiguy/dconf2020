import taggedunion;

@safe:
void foo(ref int x, ref int* ptr) {
    import std.stdio;
    x += 4; // next integer
    writeln(*ptr);
}

int publicVal = 1;
private int secretVal = 42;

void main() {
    auto item = Tagged!(int, int *)(5);
    void helper(ref int x) {
        item = &publicVal;
        foo(x, item.get!(int *));
    }

    helper(item.get!int);
}
