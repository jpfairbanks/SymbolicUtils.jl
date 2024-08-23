using Test
using SymbolicUtils
using SymbolicUtils: symtype, inspect, pluck, setmetadata, hasmetadata, getmetadata, Sym

struct ScopeCtx end

a , b, c = @syms a b c
a′, b, c = @syms a b c
@test isequal(a, a′)
a  = setmetadata(a , ScopeCtx, :x)
a  = setmetadata(a , ScopeCtx, :x)
a′ = setmetadata(a′, ScopeCtx, :y)
@test isequal(a, a′)


# apparently when you make only one symbol you need to still use a common on the LHS
a, = @syms a
a′, = @syms a
@test isequal(a, a′)
a  = setmetadata(a , ScopeCtx, :x)
a  = setmetadata(a , ScopeCtx, :x)
a′ = setmetadata(a′, ScopeCtx, :y)

# Let's make our symbolic variables by hand to avoid the macro
a = Sym{Real}(name=:a)
b = Sym{Real}(name=:a)
@test isequal(a,b)
# uhoh two variables with the same name are isequal to each other
# at least they aren't literally equal, nope, they are
@test a===b

a  = setmetadata(a , ScopeCtx, (scope=:x,))
b  = setmetadata(b , ScopeCtx, :y)
# even with different metadata they isequal to each other
@test isequal(a,b)
# the metadata are different
@test getmetadata(a, ScopeCtx) != getmetadata(b, ScopeCtx)

"""    scoped_equal(a,b)

check if two terms are equal and in the same scope
"""
function scoped_equal(a,b)
  isequal(a,b) && isequal(getmetadata(a, ScopeCtx), getmetadata(b, ScopeCtx))
end

@test !scoped_equal(a,b)

# we can make namespaced variables iwth 
ab = Sym{Real}(name=Symbol("a.b"))
