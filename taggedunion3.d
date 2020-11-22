module taggedunion;

struct Tagged(T1, T2) {
    private union Values {
        T1 t1;
        T2 t2;
    }
    private {
        Values values; 
        bool tag;
        enum useT1 = false;
        enum useT2 = true;
    }

    @safe:
    this(T1 t1) {
        values.t1 = t1;
        tag = useT1;
    }

    this(T2 t2) {
        values.t2 = t2;
        tag = useT2;
    }

    void opAssign(T1 t1) {
        if(tag == useT2)
            destroy(values.t2);
        values.t1 = t1;
        tag = useT1;
    }

    void opAssign(T2 t2) {
        if(tag == useT1)
            destroy(values.t1);
        values.t2 = t2;
        tag = useT2;
    }

    ~this() {
        if(tag == useT2)
            destroy(values.t2);
        else
            destroy(values.t1);
    }

    ref get(T)() if (is(T == T1) || is(T == T2)) {
        import std.exception : enforce;
        enforce((tag == useT2) == is(T == T2),
                "attempt to get wrong type from tagged union of "
                ~ T1.stringof ~ ", " ~ T2.stringof);
        static if(is(T == T2))
            return values.t2;
        else
            return values.t1;
    }
}

@safe unittest {
    import std.exception : assertThrown;
    alias TU = Tagged!(int, int *);
    auto tu = TU(1);
    assert(tu.get!int == 1);
    assertThrown(tu.get!(int *));
    int *x = new int(1);
    tu = x;
    assert(tu.get!(int *) == x);
    assertThrown(tu.get!int);
}
