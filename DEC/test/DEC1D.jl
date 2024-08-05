module TestDEC1D
include("../src/DEC.jl")
using .DEC
using .DEC.DECBase
using .DEC.DEC1D
using SymbolicUtils
using SymbolicUtils: symtype, BasicSymbolic, inspect, pluck
using .DEC.DEC1D: ∂ₜ, L, Δ, Δ₁, 𝟙, ⋆₀⁻¹, d̃₀, ⋆₁, d₀
using .DEC.DEC1D: dealias, realias, resolve, unresolve
using .DEC.DEC1D: lapl_expand, lapl_contract, lapl_lin, lapl_kern

using Test
DEC1D = DEC.DEC1D

# Some example equations from the Klausmeier model
@syms n::Form0 w::Form0
@syms m::Number
@syms v::Form1

@testset "Resolving Aliases" begin
  @test isequal(DEC1D.dealias(DEC1D.dt(w)), ∂ₜ(w))
end

@testset "Resolving Types" begin
  @testset "Δ₀" begin
    e1 = DEC1D.resolvers[:resolve_Δ_Δ₀](Δ(n))
    @test isequal(e1,resolve(Δ(n)))
    lapl1 = @rule Δ(~x) => Δ₁(~x) where symtype(~x) == Form1
    @test isequal(lapl1(Δ(v)), Δ₁(v))

    # Now we can do some rewriting 
    @test isnothing(DEC1D.lapl_expand(Δ(n)))
    @test isequal(DEC1D.lapl_expand(e1), ⋆₀⁻¹(d̃₀((⋆₁)(d₀(n)))))
    @test symtype(DEC1D.lapl_expand(e1)) == Form0
    @test !isnothing(DEC1D.lapl_expand(e1))

    @show lapl_expand(e1)
    @show unresolve(lapl_expand(e1))
    # @show realias(unresolve(lapl_expand(e1)))
    @show dealias(DEC1D.lapl(n))
    @show realias(dealias(DEC1D.lapl(n)))
    @show realias(lapl_expand(Δ(n)))

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