module taggedunion;

struct BorrowedRef(T) {
    this(T* val, int *cnt)
    {
        this.val = val;
        this.count = cnt;
        ++(*this.count);
    }

    private int *count;
    private T *val;

    @disable this(this); // disable copying
    ~this() { --(*count); }

    void opAssign(V)(auto ref V v) { *val = v; } // bug 16426

    @property ref T _get() { return *val; }
    alias _get this;
}

struct Tagged(T1, T2) {
    private union Values {
        T1 t1;
        T2 t2;
    }
    private {
        Values values; 
        bool tag;
        int borrowers;
        enum useT1 = false;
        enum useT2 = true;
    }

    this(this) { borrowers = 0;}

    @safe:
    this(T1 t1) {
        setTag(useT1);
        accessValue!useT1() = t1;
    }


    this(T2 t2) {
        setTag(useT2);
        accessValue!useT2() = t2;
    }

    @trusted private @property accessValue(bool expectedTag)() {
        import std.exception;
        enforce(tag == expectedTag, "attempt to get wrong type from tagged union of "
                ~ T1.stringof ~ ", " ~ T2.stringof);
        static if(expectedTag == useT2)
            return BorrowedRef!T2(&values.t2, &borrowers);
        else
            return BorrowedRef!T1(&values.t1, &borrowers);
    }

    private void setTag(bool newTag) {
        if(tag != newTag)
        {
            import std.exception;
            enforce(borrowers == 0, "Cannot change type when someone has a reference");
            if(tag == useT2)
                destroy(accessValue!useT2._get);
            else
                destroy(accessValue!useT1._get);
        }
        () @trusted { tag = newTag; } ();
    }

    void opAssign(T1 t1) {
        setTag(useT1);
        accessValue!useT1() = t1;
    }

    void opAssign(T2 t2) {
        setTag(useT2);
        accessValue!useT2() = t2;
    }

    ~this() {
        setTag(!tag);
    }

    auto get(T)() if (is(T == T1) || is(T == T2)) {
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
