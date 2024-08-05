module DEC1D
using Base.Iterators
using SymbolicUtils
using SymbolicUtils: symtype
using ..DEC.DECBase
using SymbolicUtils.Rewriters
recursive_rule(r) = Prewalk(PassThrough(r))
fprr(r) = Fixpoint(recursive_rule(r))

form0p = x-> symtype(x) == Form0

const THEORY = DECBase.ThDEC1D
resolvers = Dict{Symbol,SymbolicUtils.Rule}()
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
    @syms $alias_name(x)
    push!(ALIASES, @rule $alias_name(~x) => $root_name(~x))
    push!(ALIAS_REVERSE, @rule $root_name(~x) => $alias_name(~x))
  end
end

# Time Derivatives
# @syms ∂ₜ(x::Form)::Form dt(x::Form0)::Form0 
@syms ∂ₜ(x::Form)::Form 
@alias ∂ₜ dt

@syms ∂ₜ₀(x::Form0)::Form0 dt_0(x::Form0)::Form0
@syms ∂ₜ₁(x::Form1)::Form1 dt_1(x::Form1)::Form1

# Exterior Derivative 
@syms d(x::PrimalForm)::PrimalForm d₀(x::Form0)::Form1 
@syms d̃(x::DualForm)::DualForm dual_d₀(x::DualForm0)::DualForm1 d̃₀(x::DualForm0)::DualForm1

resolvers[:d₀] = @rule d(~x::form0p) => d₀(~x)
# resolvers[:d₁] = @rule d(~x::form0p) => d₁(~x)
resolvers[:d̃] = @rule d(~x::DualForm0) => d̃₀(~x)

# Hodge Duality
@syms (⋆)(x::PrimalForm)::DualForm (⋆₀)(x::Form0)::DualForm1 (⋆₁)(x::Form1)::DualForm0 
@syms star(x::PrimalForm)::DualForm star_1(x::Form1)::DualForm0

@syms star_inv(x::Form)::DualForm
@syms (⋆₀⁻¹)(x::DualForm1)::Form0 star_0_inv(x::DualForm1)::Form0
@syms (⋆₁⁻¹)(x::DualForm0)::Form1 star_1_inv(x::DualForm0)::Form1

# Laplacian Operators
@syms Δ(x::Form)::Form 
@syms Δ₀(x::Form0)::Form0 lapl_0(x::Form0)::Form0 
@syms Δ₁(x::Form1)::Form1 lapl_1(x::Form1)::Form1 

resolvers[:Δ₀] = @rule Δ(~x::form0p) => Δ₀(~x)
# resolvers[:Δ₁] = @rule Δ(~x::Form1) => Δ₁(~x)

# Codifferentials
@syms δ(x::Form)::Form 
@syms δ₁(x::Form1)::Form0 codif_1(x::Form1)::Form0 

# Negation as a function
# TODO: probably don't need this because of numeric_rules
@syms neg(x::Form)::Form
@syms neg_0(x::Form0)::Form0 neg_1(x::Form1)::Form1

# Misc. Operators
@syms avg₀₁(x::Form0)::Form1 avg_01(x::Form0)::Form1 
@syms mag(x::Form)::Form norm(x::Form)::Form 
@syms mag_0(x::Form0)::Form0 norm_0(x::Form0)::Form0 
@syms mag_1(x::Form1)::Form1 norm_1(x::Form1)::Form1

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


resolve = fprr(RestartedChain(values(resolvers)))
resolve_alias = fprr(RestartedChain(ALIASES))
end # module
