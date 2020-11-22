module systemtag;

struct SystemTag
{
    private bool _tag;
    @system opAssign(bool newValue) {
        _tag = newValue;
    }
    @system opAssign(SystemTag st) {
        this._tag = st._tag;
    }
    @safe tag() {
        return _tag;
    }

    alias tag this;
}
