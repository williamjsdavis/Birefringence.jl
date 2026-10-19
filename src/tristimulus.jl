# https://en.wikipedia.org/wiki/CIE_1931_color_space

"Trapezoidal quadrature weights for a (possibly irregular) wavelength grid"
function quadrature_weights(λ_vector)
    n = length(λ_vector)
    w = zeros(n)
    for i in 1:(n - 1)
        h = λ_vector[i+1] - λ_vector[i]
        w[i] += h / 2
        w[i+1] += h / 2
    end
    return w
end

"Quadrature weights multiplied by the illuminant's spectrum"
illuminant_weights(λ_vector, illuminant::Illuminant) =
    quadrature_weights(λ_vector) .* spd.(Ref(illuminant), λ_vector)

"""
Normalisation constant k = 1/∫S(λ)ȳ(λ)dλ, so that a sample transmitting all
light has luminance Y = 1
"""
normalisation(x̄ȳz̄, w) = 1 / sum(x̄ȳz̄[2,:] .* w)

"""
Spectral transmission matrix to CIE XYZ tristimulus values, for a sample lit
by `illuminant`. Normalised so that full transmission has Y = 1.
"""
function L_XYZ(λ_vector, Γ_vector, illuminant::Illuminant=D65())
    w = illuminant_weights(λ_vector, illuminant)
    x̄ȳz̄ = CIE_standard(λ_vector)
    return normalisation(x̄ȳz̄, w) * x̄ȳz̄ * (w .* Iλ(λ_vector, Γ_vector))
end

"CIE XYZ of the illuminant itself (full transmission), with Y = 1"
function white_XYZ(λ_vector, illuminant::Illuminant)
    w = illuminant_weights(λ_vector, illuminant)
    x̄ȳz̄ = CIE_standard(λ_vector)
    return normalisation(x̄ȳz̄, w) * x̄ȳz̄ * w
end

"Convert XYZ data (one color per column) to xyY format"
function xyY(XYZ)
    s = sum(XYZ, dims=1)
    return vcat(XYZ[1:1,:] ./ s, XYZ[2:2,:] ./ s, XYZ[2:2,:])
end
