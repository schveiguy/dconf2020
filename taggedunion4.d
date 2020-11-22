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
        setTag(useT1);
        accessValue!useT1 = t1;
    }

    this(T2 t2) {
        setTag(useT2);
        accessValue!useT2 = t2;
    }

    @trusted private ref accessValue(bool expectedTag)()
    {
        import std.exception;
        enforce(tag == expectedTag, "attempt to get wrong type from tagged union of "
                ~ T1.stringof ~ ", " ~ T2.stringof);
        static if(expectedTag == useT2)
            return values.t2;
        else
            return values.t1;
    }

    @trusted private void setTag(bool newTag)
    {
        if(tag != newTag)
        {
            if(tag == useT2)
                destroy(values.t2);
            else
                destroy(values.t1);
        }
        tag = newTag;
    }

    void opAssign(T1 t1) {
        setTag(useT1);
        accessValue!useT1 = t1;
    }

    void opAssign(T2 t2) {
        setTag(useT2);
        accessValue!useT2 = t2;
    }

    ~this() {
        setTag(!tag);
    }

    ref get(T)() if (is(T == T1) || is(T == T2)) {
        static if(is(T == T2))
            return accessValue!useT2;
        else
            return accessValue!useT1;
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
