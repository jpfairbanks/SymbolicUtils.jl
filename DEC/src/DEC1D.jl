module DEC1D
using Base.Iterators
using SymbolicUtils
using SymbolicUtils: symtype
using ..DEC.DECBase
using SymbolicUtils.Rewriters
recursive_rule(r) = Prewalk(PassThrough(r))
fprr(r) = Fixpoint(recursive_rule(r))

hastype(x, T) = symtype(x) == T

const THEORY = DECBase.ThDEC1D
resolvers = Dict{Any,SymbolicUtils.Rule}()
resolvers_reverse = []
@syms L(v::Form1, x::DualForm0)::DualForm0
@syms ∧(x::Form0, y::Form1)::Form1
@syms d̃(x::DualForm1)::DualForm0
# @syms ∂ₜ(x::DualForm0)::DualForm0
# @syms Δ(x::DualForm0)::DualForm0
# @syms d(x::Form0)::Form1
# @syms ⋆₀(x::Form0)::DualForm0
# @syms ⋆₁(x::Form1)::DualForm1
# @syms ⋆₀⁻¹(x::DualForm0)::Form0
# @syms ⋆₁⁻¹(x::DualForm1)::Form1

ALIASES = []
ALIAS_REVERSE = []

macro alias(root_name, alias_name)
  quote
    @syms $alias_name(x)::Form
    push!(ALIASES, @rule $alias_name(~x) => $root_name(~x))
    push!(ALIAS_REVERSE, @rule $root_name(~x) => $alias_name(~x))
  end
end

macro resolution(op, resolveto, src_type, tgt_type)
  rulename = Symbol("resolve_$(op)_$resolveto")
  key = QuoteNode(rulename)
  quote
    @syms $resolveto(x::$src_type)::$tgt_type
    $rulename = @rule $op(~x) => (hastype(~x,$src_type) ? $resolveto(~x) : nothing)
    resolvers[$key] = $rulename 
    push!(resolvers_reverse, @rule $resolveto(~x) => $op(~x))
  end
end

# Time Derivatives
@syms ∂ₜ(x::Form)::Form 

@resolution ∂ₜ ∂ₜ₀ Form0 Form0
@resolution ∂ₜ ∂ₜ₁ Form1 Form1
@alias ∂ₜ dt

# Exterior Derivative 
@syms d(x::PrimalForm)::PrimalForm
@syms d̃(x::DualForm)::DualForm 

@resolution d d₀ Form0 Form1
@resolution d̃ d̃₀ DualForm0 DualForm1
@alias d̃₀ dual_d₀

# Hodge Duality
@syms (⋆)(x::PrimalForm)::DualForm (⋆₀)(x::Form0)::DualForm1 (⋆₁)(x::Form1)::DualForm0 
@resolution (⋆) (⋆₀) Form0 DualForm1
@resolution (⋆) (⋆₁) Form1 DualForm0
@alias (⋆) star

@syms (⋆⁻¹)(x::DualForm)::PrimalForm
@resolution (⋆⁻¹) (⋆₀⁻¹) DualForm1 Form0
@resolution (⋆⁻¹) (⋆₁⁻¹) DualForm0 Form1
@alias (⋆₀⁻¹) star_0_inv
@alias (⋆₁⁻¹) star_1_inv

# Laplacian Operators
@syms Δ(x::Form)::Form 
@resolution Δ Δ₀ Form0 Form0
@resolution Δ Δ₁ Form1 Form1
@alias Δ lapl
@alias Δ₀ lapl_0
@alias Δ₁ lapl_1

# Codifferentials
@syms δ(x::Form)::Form 
@resolution δ δ₁ Form1 Form0
@alias δ codif
@alias δ₁ codif_1

# Negation as a function
# TODO: probably don't need this because of numeric_rules
@syms neg(x::Form)::Form
@syms neg_0(x::Form0)::Form0 neg_1(x::Form1)::Form1

# Misc. Operators
@syms avg₀₁(x::Form0)::Form1
@alias avg₀₁ avg_01

@syms mag(x::Form)::Form 
@resolution mag mag_0 Form0 Form0
@resolution mag mag_1 Form1 Form1

@syms norm(x::Form)::Form 
@resolution norm norm_0 Form0 Form0
@resolution norm norm_1 Form1 Form1

# const OPERATORS = [∂ₜ, L, Δ, ∧, d, d̃, ⋆₀,⋆₁, ⋆₀⁻¹, ⋆₁⁻¹]
@syms 𝟙::DualForm0
const CONSTANTS = [𝟙]
# operators and rules that you define once per dimension
# lapl_expand = @rule Δ₀(~x) => d̃(⋆₁(d(⋆₀⁻¹(~x))))
lapl_expand = @rule Δ₀(~x) => (⋆₀⁻¹)(d̃₀((⋆₁)(d₀((~x)))))
lapl_contract = @rule d̃(⋆₁(d(⋆₀⁻¹(~x)))) => Δ(~x)
lapl_lin = @rule Δ(~x + ~y) => Δ(~x) + Δ(~y)
lapl_kern = @rule Δ(𝟙) => 0
const RULES = [lapl_expand,
  lapl_contract,
  lapl_lin,
  lapl_kern]


resolve   = fprr(RestartedChain(values(resolvers)))
unresolve = fprr(RestartedChain(values(resolvers_reverse)))
dealias   = fprr(RestartedChain(ALIASES))
realias   = fprr(RestartedChain(ALIAS_REVERSE))
end # module
