module DEC
include("DECBase.jl")
include("DEC1D.jl")
using SymbolicUtils
using SymbolicUtils: symtype, BasicSymbolic
using SymbolicUtils.Rewriters

export DECBase, DEC1D, recursive_rule, Decapode

moduleof(::Type{DECBase.ThDEC1D}) = DEC1D
moduleof(::Type{DECBase.ThDEC2D}) = DEC2D
moduleof(::Type{DECBase.ThDEC3D}) = DEC3D

recursive_rule(r) = Prewalk(PassThrough(r))

dom(t::BasicSymbolic) = symtype(t).parameters[1].parameters
codom(t::BasicSymbolic) = symtype(t).parameters[2]

struct Decapode
  theory::Module
  vars::Vector{BasicSymbolic}
  ops::Vector{BasicSymbolic}
  eqns::Vector{BasicSymbolic}
end

Base.show(io::IO, d::Decapode) = begin
  println(io, "Decapode(")
  println(io, "  Theory: $(d.theory.THEORY)")
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

end #module