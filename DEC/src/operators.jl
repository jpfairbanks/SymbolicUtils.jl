function default_dec_matrix_generate(sd::HasDeltaSet, my_symbol::Symbol, hodge::DiscreteHodge)
  op = @match my_symbol begin

    # Regular Hodge Stars
    :⋆₀ => dec_mat_hodge(0, sd, hodge)
    :⋆₁ => dec_mat_hodge(1, sd, hodge)
    :⋆₂ => dec_mat_hodge(2, sd, hodge)

    # Inverse Hodge Stars
    :⋆₀⁻¹ => dec_mat_inverse_hodge(0, sd, hodge)
    :⋆₁⁻¹ => dec_pair_inv_hodge(Val{1}, sd, hodge) # Special since Geo is a solver
    :⋆₂⁻¹ => dec_mat_inverse_hodge(1, sd, hodge)

    # Differentials
    :d₀ => dec_mat_differential(0, sd)
    :d₁ => dec_mat_differential(1, sd)

    # Dual Differentials
    :dual_d₀ || :d̃₀ => dec_mat_dual_differential(0, sd)
    :dual_d₁ || :d̃₁ => dec_mat_dual_differential(1, sd)

    # Wedge Products
    :∧₀₁ => dec_pair_wedge_product(Tuple{0,1}, sd)
    :∧₁₀ => dec_pair_wedge_product(Tuple{1,0}, sd)
    :∧₀₂ => dec_pair_wedge_product(Tuple{0,2}, sd)
    :∧₂₀ => dec_pair_wedge_product(Tuple{2,0}, sd)
    :∧₁₁ => dec_pair_wedge_product(Tuple{1,1}, sd)

    # Primal-Dual Wedge Products
    :∧ᵖᵈ₁₁ => dec_wedge_product_pd(Tuple{1,1}, sd)
    :∧ᵖᵈ₀₁ => dec_wedge_product_pd(Tuple{0,1}, sd)
    :∧ᵈᵖ₁₁ => dec_wedge_product_dp(Tuple{1,1}, sd)
    :∧ᵈᵖ₁₀ => dec_wedge_product_dp(Tuple{1,0}, sd)

    # Dual-Dual Wedge Products
    :∧ᵈᵈ₁₁ => dec_wedge_product_dd(Tuple{1,1}, sd)
    :∧ᵈᵈ₁₀ => dec_wedge_product_dd(Tuple{1,0}, sd)
    :∧ᵈᵈ₀₁ => dec_wedge_product_dd(Tuple{0,1}, sd)

    # Dual-Dual Interior Products
    :ι₁₁ => interior_product_dd(Tuple{1,1}, sd)
    :ι₁₂ => interior_product_dd(Tuple{1,2}, sd)

    # Dual-Dual Lie Derivatives
    :ℒ₁ => ℒ_dd(Tuple{1,1}, sd)

    # Dual Laplacians
    :Δᵈ₀ => Δᵈ(Val{0},sd)
    :Δᵈ₁ => Δᵈ(Val{1},sd)

    # Musical Isomorphisms
    :♯ => dec_♯_p(sd)
    :♯ᵈ => dec_♯_d(sd)

    :♭ => dec_♭(sd)

    # Averaging Operator
    :avg₀₁ => dec_avg₀₁(sd)

    :neg => x -> -1 .* x
     _ => error("Unmatched operator $my_symbol")
  end

  return op
end