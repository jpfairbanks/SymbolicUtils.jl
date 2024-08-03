using SymbolicUtils
using SymbolicUtils: symtype
using SymbolicUtils: BasicSymbolic, Add, basicsymbolic, inspect, pluck
using SymbolicUtils.Rewriters
recursive_rule(r) = Prewalk(PassThrough(r))

abstract type Form <: Number end
abstract type PrimalForm <: Form end
abstract type DualForm <: Form end

struct Form0 <: PrimalForm end
struct Form1 <: PrimalForm end
struct Form2 <: PrimalForm end
struct DualForm0 <: DualForm end
struct DualForm1 <: DualForm end
struct DualForm2 <: DualForm end

struct Constant{T} <: Number end
struct Parameter{T} <: Number end

# SymbolicUtils.islike(::BasicSymbolic{DualForm0}, ::Type{Number}) = true
SymbolicUtils.@number_methods(BasicSymbolic{<:Form}, term(f,a), term(f,a,b), onlybasics)

dom(t::BasicSymbolic) = symtype(t).parameters[1].parameters
codom(t::BasicSymbolic) = symtype(t).parameters[2]

struct Decapode
  vars::Vector{BasicSymbolic}
  ops::Vector{BasicSymbolic}
  eqns::Vector{BasicSymbolic}
end

Base.show(io::IO, d::Decapode) = begin
  println(io, "Decapode(")
  println(io, "  Variables: [$(join(d.vars, ", "))]")
  signatures = map(d.ops) do op
    domstr = join(dom(op), "×")
    "    $op: $(domstr) → $(codom(op))"
  end
  println(io, "  Operators:\n$(join(signatures, ",\n"))")
  println(io, "  Equations: [")
  eqns = map(d.eqns) do op
    "    $(op)"
  end
  println(io, "$(join(eqns,",\n"))])")
end

# operators and rules that you define once per dimension
@syms ∂ₜ(x::DualForm0)::DualForm0
@syms L(v::Form1, x::DualForm0)::DualForm0 
@syms Δ(x::DualForm0)::DualForm0 
@syms ∧(x::Form0, y::Form1)::Form1 
@syms d(x::Form0)::Form1
@syms d̃(x::DualForm1)::DualForm0
@syms ⋆₀(x::Form0)::DualForm0
@syms ⋆₁(x::Form1)::DualForm1
@syms ⋆₀⁻¹(x::DualForm0)::Form0
@syms ⋆₁⁻¹(x::DualForm1)::Form1
lapl_expand = @rule Δ(~x) => d̃(⋆₁(d(⋆₀⁻¹(~x))))
lapl_contract = @rule d̃(⋆₁(d(⋆₀⁻¹(~x)))) => Δ(~x)
lapl_lin = @rule Δ(~x + ~y) => Δ(~x) + Δ(~y)
@syms 𝟙::DualForm0
lapl_kern = @rule Δ(𝟙) => 0
ops1D = [∂ₜ, L, Δ, ∧, d, d̃, ⋆₀,⋆₁, ⋆₀⁻¹, ⋆₁⁻¹]

#=
# See Klausmeier Equation 2.a
Hydrodynamics = @decapode begin
  (n,w)::DualForm0
  dX::Form1
  (a,ν)::Constant

  ∂ₜ(w) == a - w - w * n^2 + ν * L(dX, w)
end

# See Klausmeier Equation 2.b
Phytodynamics = @decapode begin
  (n,w)::DualForm0
  m::Constant

  ∂ₜ(n) == w * n^2 - m*n + Δ(n)
end
=#

# Variables we define for our specific model
@syms n::DualForm0 w::DualForm0 dX::Form1 a::Constant{DualForm0} ν::Constant{DualForm0}
@syms m::Number

hydro_eqn = ∂ₜ(w) == a + w + (w * (n^2)) + ν * L(dX,w)
phyto_eqn = ∂ₜ(n) == w * n^2 - m*n + Δ(n)

dp = Decapode(
  [n,w,dX,a,ν,m],
  ops1D,
  [hydro_eqn, phyto_eqn]
)

eqn2 = lapl_expand(Δ(n))

eqn2 = recursive_rule(lapl_expand)(phyto_eqn)
dp.eqns[2] = eqn2
@show dp

eqn2 = recursive_rule(lapl_contract)(phyto_eqn)
dp.eqns[2] = eqn2
dp

lapleqn = ∂ₜ(w) == Δ(w + 𝟙)
lapleqn = recursive_rule(lapl_lin)(lapleqn)
lapleqn = recursive_rule(lapl_kern)(lapleqn)
lapleqn = simplify(lapleqn)
