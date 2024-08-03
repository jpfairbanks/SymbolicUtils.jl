"""    Graded

This file looks at multiple ways of introducing graded types to your terms.
The only one that works is to use an operator x⁝(i::Int) where.
Then rewrite rules can manipulate the grading when they execute.
"""
module Graded
using Test
using SymbolicUtils
using SymbolicUtils: symtype
using SymbolicUtils.Rewriters
recursive_rule(r) = Prewalk(PassThrough(r))
fprr(r) = Fixpoint(recursive_rule(r))

struct Form{Dim, Dual} <: Number end

Form0 = Form{0, false}
Form1 = Form{1, false}
Form2 = Form{2, false}
DForm0 = Form{0, true}
DForm1 = Form{1, true}
DForm2 = Form{2, true}

N = 2

@syms x::Form0
@syms d(x::Form0)::Form1
@syms d(x::Form1)::Form2
# @syms d(x::DForm0)::DForm1
# @syms d(x::DForm1)::DForm2
# @syms ⋆(x::Form{i,b})::Form{N-i,!b} where {i,b}
@syms ⋆(x::Form{0,true})::Form{N-0,false}
@syms ⋆(x::Form{1,true})::Form{N-1,false}
@syms ⋆(x::Form{2,true})::Form{N-2,false}
@syms ⋆(x::Form{0,false})::Form{N-0,true}
@syms ⋆(x::Form{1,false})::Form{N-1,true}
@syms ⋆(x::Form{2,false})::Form{N-2,true}

# This doesn't work because symbolic rules don't have multiple dispatch
# @show symtype(d(x))
# @show symtype(⋆(d(x)))

# So we try to put the grading into the values of a struct
struct VForm <: Number
  dim::Int
  duality::Bool
end

@syms x::VForm(0,false)
@show symtype(x)

@syms d(x::VForm(0,false))::VForm(1,false)
# these don't work because you can't have values as the return types of your symbolic functions.
# @show symtype d(x)

# This approach does work
struct F <: Number end

@syms y::F 
@syms 𝟘::F
@syms ⁝(x::F,i::Int)::F
@syms d(x::F)::F
@show symtype(y⁝1)
@show symtype(d(y⁝1))
d_type = @rule d(~x⁝~i) => d(~x)⁝(~i+1)
d_type_rev = @rule d(~x)⁝(~i) => d(~x⁝~i-1)

@testset "Grade Inference" begin
@show d_type
@show d_type_rev

@test isequal(d_type(d(y⁝0)), d(y)⁝1)
# @show d_type(d(y⁝1))
# @show recursive_rule(d_type)(d(d(y⁝0)))

d2y = d(d(y⁝0))
expr1 = @show fprr(d_type)(d2y)
expr2 = @show fprr(d_type_rev)(expr1)

@test isequal(expr1, d(d(y))⁝2)
@test isequal(d2y,expr2)

# The big differentially graded rule d^2=0!
d2_zero = @rule d(d(~x))⁝~i => 𝟘⁝~i

fp_d2_zero = fprr(d2_zero)
@test !isequal(fp_d2_zero(d2y), 𝟘⁝2)
@test isequal(fp_d2_zero(fprr(d_type)(d2y)), 𝟘⁝2)
end

# So we could try and write a series of DEC rules that use the grading information
# and just have a term constructor x⁝i that attaches the grading to the variables 
# or another expression.
end