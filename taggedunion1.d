module taggedunion;
import std.exception;

struct Tagged(T1, T2)
{
    private union Values {
        T1 t1;
        T2 t2;
    }
    private {
        Values values; 
        bool tag; // false = t1, true = t2
    }

    this(T1 t1) {
        values.t1 = t1;
        tag = false;
    }

    this(T2 t2) {
        values.t2 = t2;
        tag = true;
    }

    void opAssign(T1 t1) {
        if(tag)
            destroy(values.t2);
        values.t1 = t1;
        tag = false;
    }

    void opAssign(T2 t2) {
        if(!tag)
            destroy(values.t1);
        values.t2 = t2;
        tag = true;
    }

    ~this() {
        if(tag)
            destroy(values.t2);
        else
            destroy(values.t1);
    }

    ref get(T)() if (is(T == T1) || is(T == T2)) {
        enforce(tag == is(T == T2), "attempt to get wrong type from tagged union of "
                ~ T1.stringof ~ ", " ~ T2.stringof);
        static if(is(T == T2))
            return values.t2;
        else
            return values.t1;
    }
}

// not @safe yet
unittest {
    alias TU = Tagged!(int, int *);
    auto tu = TU(1);
    assert(tu.get!int == 1);
    assertThrown(tu.get!(int *));
    int x;
    tu = &x;
    assert(tu.get!(int *) == &x);
    assertThrown(tu.get!int);
}
