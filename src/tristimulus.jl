# https://en.wikipedia.org/wiki/CIE_1931_color_space

"Spectral transmission matrix to CIE XYZ tristimulus values"
function L_XYZ(λ_vector::AbstractRange, Γ_vector)
    #NOTE: Still unknown why the 1e-2 fudge factor is needed
    return CIE_standard(λ_vector) *
           Iλ(λ_vector, Γ_vector) * step(λ_vector) * 1e-2
end

function L_XYZ(λ_vector::AbstractVector, Γ_vector)
    n = length(Γ_vector)
    XYZ = zeros(3, n)
    x̄ȳz̄ = CIE_standard(λ_vector)
    Iλ_matrix = Iλ(λ_vector, Γ_vector)
    for i in 1:3
        for j in 1:n
            XYZ[i,j] = integrate(λ_vector, x̄ȳz̄[i,:].*Iλ_matrix[:,j])
        end
    end
    return 1e-2 * XYZ
end

"Convert XYZ data to xyY format"
function xyY(XYZ)
    n = length(Γ_vector)
    XYZ = zeros(3, n)
    x̄ȳz̄ = CIE_standard(λ_vector)
    Iλ_matrix = Iλ(λ_vector, Γ_vector)
    for i in 1:3
        for j in 1:n
            XYZ[i,j] = integrate(λ_vector, x̄ȳz̄[i,:].*Iλ_matrix[:,j])
        end
    end
    return 1e-2 * XYZ
end
