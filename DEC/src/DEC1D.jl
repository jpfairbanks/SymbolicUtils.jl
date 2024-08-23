module DEC1D
using SymbolicUtils
using ..DEC.DECBase
const THEORY = DECBase.ThDEC1D
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
const OPERATORS = [∂ₜ, L, Δ, ∧, d, d̃, ⋆₀,⋆₁, ⋆₀⁻¹, ⋆₁⁻¹]
@syms 𝟙::DualForm0
const CONSTANTS = [𝟙]
# operators and rules that you define once per dimension
lapl_expand = @rule Δ(~x) => d̃(⋆₁(d(⋆₀⁻¹(~x))))
lapl_contract = @rule d̃(⋆₁(d(⋆₀⁻¹(~x)))) => Δ(~x)
lapl_lin = @rule Δ(~x + ~y) => Δ(~x) + Δ(~y)
lapl_kern = @rule Δ(𝟙) => 0
const RULES = [lapl_expand,
  lapl_contract,
  lapl_lin,
  lapl_kern]
end