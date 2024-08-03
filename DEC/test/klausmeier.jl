module Klausmeier
include("../src/DEC.jl")
using .DEC
using .DEC.DECBase
using .DEC.DEC1D
using SymbolicUtils
using SymbolicUtils: symtype, BasicSymbolic

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

# Bring the operators we need into scope:
DEC1D = DEC.DEC1D

∂ₜ = DEC1D.∂ₜ
L = DEC1D.L
Δ = DEC1D.Δ
𝟙 = DEC1D.𝟙

# Variables we define for our specific model
@syms n::DualForm0 w::DualForm0 dX::Form1 a::Constant{DualForm0} ν::Constant{DualForm0}
@syms m::Number
# The equations for our model
hydro_eqn = ∂ₜ(w) == a + w + (w * (n^2)) + ν * L(dX,w)
phyto_eqn = ∂ₜ(n) == w * n^2 - m*n + Δ(n)
# package it into a decapode struct.
dp = Decapode(DEC1D,
  [n,w,dX,a,ν,m],        # the variables for this model
  BasicSymbolic[],       # no local operators
  [hydro_eqn, phyto_eqn] # the equations
)

# Now we can do some rewriting tests
using Test
@show DEC1D.lapl_expand(Δ(n))

eqn2 = recursive_rule(DEC1D.lapl_expand)(phyto_eqn)
dp.eqns[2] = eqn2
@test !isequal(eqn2, phyto_eqn)

eqn2 = recursive_rule(DEC1D.lapl_contract)(phyto_eqn)
@test isequal(eqn2, phyto_eqn)
@show dp

@info "Rewriting Demo"
lapleqn = ∂ₜ(w) == Δ(w + 𝟙)
@info lapleqn rule=DEC1D.lapl_lin
lapleqn = recursive_rule(DEC1D.lapl_lin)(lapleqn)
@info lapleqn rule=DEC1D.lapl_kern
lapleqn = recursive_rule(DEC1D.lapl_kern)(lapleqn)
@info lapleqn rule=:symplify
lapleqn = simplify(lapleqn)
@info lapleqn
@test isequal(lapleqn, ∂ₜ(w) == Δ(w))
end