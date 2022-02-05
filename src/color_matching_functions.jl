# The CIE XYZ standard observer color matching functions
function piecewise_gaussian(x, μ, σ₁, σ₂)
    if x < μ
        return exp(-oftype(x,0.5)*(x-μ)^2/σ₁^2)
    else
        return exp(-oftype(x,0.5)*(x-μ)^2/σ₂^2)
    end
end

x̄(λ) = (1.056*piecewise_gaussian(λ, 599.8, 37.9, 31.0)
      + 0.362*piecewise_gaussian(λ, 442.0, 16.0, 26.7)
      - 0.065*piecewise_gaussian(λ, 501.1, 20.4, 26.2))

ȳ(λ) = (0.821*piecewise_gaussian(λ, 568.8, 49.9, 40.5)
      + 0.286*piecewise_gaussian(λ, 530.9, 16.3, 31.1))

z̄(λ) = (1.217*piecewise_gaussian(λ, 437.0, 11.8, 36.0)
      + 0.681*piecewise_gaussian(λ, 459.0, 26.0, 13.8))

"""
CIE's color matching functions for a standard (colorimetric) observer

In (x̄,ȳ,z̄) order, sometimes refered to (r̄,ḡ,b̄)

Reference: https://en.wikipedia.org/wiki/CIE_1931_color_space#Color_matching_functions
"""
CIE_standard(λ_array) = [f(λ) for f in [x̄,ȳ,z̄], λ in λ_array]
