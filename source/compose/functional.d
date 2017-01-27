module compose.functional;


// skip all ASCII chars except a..z, A..Z, 0..9, '_' and '.'.
uint _ctfeSkipOp(ref string op)
{
    if (!__ctfe) assert(false);
    import std.ascii : isASCII, isAlphaNum;
    immutable oldLength = op.length;
    while (op.length)
	{
	    immutable front = op[0];
	    if (front.isASCII() && !(front.isAlphaNum() || front == '_' || front == '.'))
		op = op[1..$];
	    else
		break;
	}
    return oldLength != op.length;
}

// skip all digits
uint _ctfeSkipInteger(ref string op)
{
    if (!__ctfe) assert(false);
    import std.ascii : isDigit;
    immutable oldLength = op.length;
    while (op.length)
	{
	    immutable front = op[0];
	    if (front.isDigit())
		op = op[1..$];
	    else
		break;
	}
    return oldLength != op.length;
}

// skip name
uint _ctfeSkipName(ref string op, string name)
{
    if (!__ctfe) assert(false);
    if (op.length >= name.length && op[0..name.length] == name)
	{
	    op = op[name.length..$];
	    return 1;
	}
    return 0;
}

// returns 1 if $(D fun) is trivial unary function
uint _ctfeMatchUnary(string fun, string name)
{
    if (!__ctfe) assert(false);
    fun._ctfeSkipOp();
    for (;;)
	{
	    immutable h = fun._ctfeSkipName(name) + fun._ctfeSkipInteger();
	    if (h == 0)
		{
		    fun._ctfeSkipOp();
		    break;
		}
	    else if (h == 1)
		{
		    if (!fun._ctfeSkipOp())
			break;
		}
	    else
		return 0;
	}
    return fun.length == 0;
}
