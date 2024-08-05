module TestDEC1D
include("../src/DEC.jl")
using .DEC
using .DEC.DECBase
using .DEC.DEC1D
using SymbolicUtils
using SymbolicUtils: symtype, BasicSymbolic, inspect, pluck
using .DEC.DEC1D: ∂ₜ, L, Δ, 𝟙, ⋆₀⁻¹, d̃₀, ⋆₁, d₀

using Test
DEC1D = DEC.DEC1D

# Some example equations from the Klausmeier model
@syms n::Form0 w::Form0
@syms m::Number

@testset "Resolving Aliases" begin
  @test isequal(DEC1D.resolve_alias(DEC1D.dt(w)), ∂ₜ(w))
end

@testset "Resolving Types" begin
  @testset "Δ₀" begin
    e1 = DEC1D.resolvers[:Δ₀](Δ(n))
    @test isequal(e1,DEC1D.resolve(Δ(n)))

    # Now we can do some rewriting tests
    @test isnothing(DEC1D.lapl_expand(Δ(n)))
    @test isequal(DEC1D.lapl_expand(e1), ⋆₀⁻¹(d̃₀((⋆₁)(d₀(n)))))
    @test symtype(DEC1D.lapl_expand(e1)) == Form0
    @test !isnothing(DEC1D.lapl_expand(e1))

    phyto_eqn = ∂ₜ(n) == w * n^2 - m*n + Δ(n)
    phyto_eqn = DEC1D.resolve(phyto_eqn)

    eqn2 = recursive_rule(DEC1D.lapl_expand)(phyto_eqn)
    @test !isequal(eqn2, phyto_eqn)

    eqn2 = recursive_rule(DEC1D.lapl_contract)(phyto_eqn)
    @test isequal(eqn2, phyto_eqn)
  end

  @testset "Laplacian Symplification" begin
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
end # testset
end # module