
abstract type AbstractRule end
abstract type InferenceRule end

struct InferenceRule1 <: InferenceRule
  src_type
  tgt_type
  op_names
end
InferenceRule1(t) = InferenceRule1(t...)

struct InferenceRule2 <: InferenceRule
  proj1_type
  proj2_type
  res_type
  op_names
end
InferenceRule2(t) = InferenceRule2(t...)

struct ResolutionRule <: AbstractRule
  src_type
  tgt_type
  resolved_name
  op
end
ResolutionRule(t) = ResolutionRule(t...)

"""
These are the default rules used to do type inference in the 1D exterior calculus.
"""
op1_inf_rules_1D = InferenceRule1.([
  # Rules for ∂ₜ 
  (:Form0, :Form0, [:∂ₜ,:dt]),
  (:Form1, :Form1, [:∂ₜ,:dt]),

  # Rules for d
  (:Form0, :Form1, [:d, :d₀]),
  (:DualForm0, :DualForm1, [:d, :dual_d₀, :d̃₀]),

  # Rules for ⋆
  (:Form0, :DualForm1, [:⋆, :⋆₀, :star]),
  (:Form1, :DualForm0, [:⋆, :⋆₁, :star]),
  (:DualForm1, :Form0, [:⋆, :⋆₀⁻¹, :star_inv]),
  (:DualForm0, :Form1, [:⋆, :⋆₁⁻¹, :star_inv]),

  # Rules for Δ
  (:Form0, :Form0, [:Δ, :Δ₀, :lapl]),
  (:Form1, :Form1, [:Δ, :Δ₁, :lapl]),

  # Rules for δ
  (:Form1, :Form0, [:δ, :δ₁, :codif]),

  # Rules for negation
  (:Form0, :Form0, [:neg, :(-)]),
  (:Form1, :Form1, [:neg, :(-)]),
  
  # Rules for the averaging operator
  (:Form0, :Form1, [:avg₀₁, :avg_01]),
  
  # Rules for magnitude/ norm
  (:Form0, :Form0, [:mag, :norm]),
  (:Form1, :Form1, [:mag, :norm])])

    using Base.Iterators
  function op1_generate(op1rules)
    map(op1rules) do op
      root_name = op.op_names[1]
      term_constructors = map(op.op_names) do alias
        :($alias(x::$(op.src_type))::$(op.tgt_type))
      end

      alias_rules = map(op.op_names[2:end]) do alias
        :($alias(~x) => $root_name(~x))
      end
      return root_name, (term_constructors, alias_rules)
    end
  end

    defblock = :(@syms)
  for op in op1_generate(op1_inf_rules_1D)
    # println(op)
    for def in op[2][1]
      push!(defblock.args, def)
    end
    # for def in op[2][2]
    #   println(:(@rule $def))
    # end
  end
    println(defblock)

# op2_inf_rules_1D = [
#   # Rules for ∧₀₀, ∧₁₀, ∧₀₁
#   (proj1_type = :Form0, proj2_type = :Form0, res_type = :Form0, op_names = [:∧, :∧₀₀, :wedge]),
#   (proj1_type = :Form1, proj2_type = :Form0, res_type = :Form1, op_names = [:∧, :∧₁₀, :wedge]),
#   (proj1_type = :Form0, proj2_type = :Form1, res_type = :Form1, op_names = [:∧, :∧₀₁, :wedge]),

#   # Rules for L₀, L₁
#   (proj1_type = :Form1, proj2_type = :DualForm0, res_type = :DualForm0, op_names = [:L, :L₀]),
#   (proj1_type = :Form1, proj2_type = :DualForm1, res_type = :DualForm1, op_names = [:L, :L₁]),    

#   # Rules for i₁
#   (proj1_type = :Form1, proj2_type = :DualForm1, res_type = :DualForm0, op_names = [:i, :i₁]),

#   # Rules for divison and multiplication
#   (proj1_type = :Form0, proj2_type = :Form0, res_type = :Form0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Form1, proj2_type = :Form1, res_type = :Form1, op_names = [:/, :./, :*, :.*, :^, :.^]),

#   # WARNING: This parameter type inference might be wrong, depending on what the user gives as a parameter
#   #= (proj1_type = :Parameter, proj2_type = :Form0, res_type = :Form0, op_names = [:/, :./, :*, :.*]),
#   (proj1_type = :Parameter, proj2_type = :Form1, res_type = :Form1, op_names = [:/, :./, :*, :.*]),
#   (proj1_type = :Parameter, proj2_type = :Form2, res_type = :Form2, op_names = [:/, :./, :*, :.*]),

#   (proj1_type = :Form0, proj2_type = :Parameter, res_type = :Form0, op_names = [:/, :./, :*, :.*]),
#   (proj1_type = :Form1, proj2_type = :Parameter, res_type = :Form1, op_names = [:/, :./, :*, :.*]),
#   (proj1_type = :Form2, proj2_type = :Parameter, res_type = :Form2, op_names = [:/, :./, :*, :.*]),=#
  
#   (proj1_type = :Form0, proj2_type = :Literal, res_type = :Form0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Form1, proj2_type = :Literal, res_type = :Form1, op_names = [:/, :./, :*, :.*, :^, :.^]),
  
#   (proj1_type = :DualForm0, proj2_type = :Literal, res_type = :DualForm0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :DualForm1, proj2_type = :Literal, res_type = :DualForm1, op_names = [:/, :./, :*, :.*, :^, :.^]),

#   (proj1_type = :Literal, proj2_type = :Form0, res_type = :Form0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Literal, proj2_type = :Form1, res_type = :Form1, op_names = [:/, :./, :*, :.*, :^, :.^]),

#   (proj1_type = :Literal, proj2_type = :DualForm0, res_type = :DualForm0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Literal, proj2_type = :DualForm1, res_type = :DualForm1, op_names = [:/, :./, :*, :.*, :^, :.^]),

#   (proj1_type = :Constant, proj2_type = :Form0, res_type = :Form0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Constant, proj2_type = :Form1, res_type = :Form1, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Form0, proj2_type = :Constant, res_type = :Form0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Form1, proj2_type = :Constant, res_type = :Form1, op_names = [:/, :./, :*, :.*, :^, :.^]),
  
#   (proj1_type = :Constant, proj2_type = :DualForm0, res_type = :DualForm0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :Constant, proj2_type = :DualForm1, res_type = :DualForm1, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :DualForm0, proj2_type = :Constant, res_type = :DualForm0, op_names = [:/, :./, :*, :.*, :^, :.^]),
#   (proj1_type = :DualForm1, proj2_type = :Constant, res_type = :DualForm1, op_names = [:/, :./, :*, :.*, :^, :.^])]

#   """
#   These are the default rules used to do function resolution in the 1D exterior calculus.
#   """
#   op1_res_rules_1D = [
#     # Rules for d.
#     (src_type = :Form0, tgt_type = :Form1, resolved_name = :d₀, op = :d),
#     (src_type = :DualForm0, tgt_type = :DualForm1, resolved_name = :dual_d₀, op = :d),
#     # Rules for ⋆.
#     (src_type = :Form0, tgt_type = :DualForm1, resolved_name = :⋆₀, op = :⋆),
#     (src_type = :Form1, tgt_type = :DualForm0, resolved_name = :⋆₁, op = :⋆),
#     (src_type = :DualForm1, tgt_type = :Form0, resolved_name = :⋆₀⁻¹, op = :⋆),
#     (src_type = :DualForm0, tgt_type = :Form1, resolved_name = :⋆₁⁻¹, op = :⋆),
#     (src_type = :Form0, tgt_type = :DualForm1, resolved_name = :⋆₀, op = :star),
#     (src_type = :Form1, tgt_type = :DualForm0, resolved_name = :⋆₁, op = :star),
#     (src_type = :DualForm1, tgt_type = :Form0, resolved_name = :⋆₀⁻¹, op = :star),
#     (src_type = :DualForm0, tgt_type = :Form1, resolved_name = :⋆₁⁻¹, op = :star),
#     # Rules for δ.
#     (src_type = :Form1, tgt_type = :Form0, resolved_name = :δ₁, op = :δ),
#     (src_type = :Form1, tgt_type = :Form0, resolved_name = :δ₁, op = :codif),
#      # Rules for Δ
#     (src_type = :Form0, tgt_type = :Form0, resolved_name = :Δ₀, op = :Δ),
#     (src_type = :Form1, tgt_type = :Form1, resolved_name = :Δ₁, op = :Δ)]
  
#   # We merge 1D and 2D rules since it seems op2 rules are metric-free. If
#   # this assumption is false, this needs to change.
#   op2_res_rules_1D = [
#     # Rules for ∧.
#     (proj1_type = :Form0, proj2_type = :Form0, res_type = :Form0, resolved_name = :∧₀₀, op = :∧),
#     (proj1_type = :Form1, proj2_type = :Form0, res_type = :Form1, resolved_name = :∧₁₀, op = :∧),
#     (proj1_type = :Form0, proj2_type = :Form1, res_type = :Form1, resolved_name = :∧₀₁, op = :∧),
#     (proj1_type = :Form0, proj2_type = :Form0, res_type = :Form0, resolved_name = :∧₀₀, op = :wedge),
#     (proj1_type = :Form1, proj2_type = :Form0, res_type = :Form1, resolved_name = :∧₁₀, op = :wedge),
#     (proj1_type = :Form0, proj2_type = :Form1, res_type = :Form1, resolved_name = :∧₀₁, op = :wedge),
#     # Rules for L.
#     (proj1_type = :Form1, proj2_type = :DualForm0, res_type = :DualForm0, resolved_name = :L₀, op = :L),
#     (proj1_type = :Form1, proj2_type = :DualForm1, res_type = :DualForm1, resolved_name = :L₁, op = :L),
#     # Rules for i.
#     (proj1_type = :Form1, proj2_type = :DualForm1, res_type = :DualForm0, resolved_name = :i₁, op = :i)]