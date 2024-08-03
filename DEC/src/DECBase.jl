module DECBase
using SymbolicUtils
using SymbolicUtils: symtype, BasicSymbolic

export Form, PrimalForm, DualForm, Form0, Form1, Form2, DualForm0, DualForm1, DualForm2, Constant, Parameter,
  ThDEC, ThDEC1D, ThDEC2D, ThDEC3D

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

abstract type AbstractTheory end
abstract type ThDEC <: AbstractTheory end
struct ThDEC1D <: ThDEC end
struct ThDEC2D <: ThDEC end
struct ThDEC3D <: ThDEC end

dimension(::Type{T}) where T<:ThDEC = error("The generic DEC does not have a fixed dimension. You need to overload dimension for type $T")
dimension(::Type{ThDEC1D}) = 1
dimension(::Type{ThDEC2D}) = 2
dimension(::Type{ThDEC3D}) = 3

moduleof(::Type{ThDEC}) = error("There is no module for dimension independent DEC yet")

end # module
