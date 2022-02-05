"""
  Transmission degrees
Reference: Bloss, F.D. (1999): Optical crystallography.
           Mineralogical Societyof America, Washington, DC
"""
L(λ, ϕ, τ, Γ) = cos(ϕ)^2 - sin(τ-ϕ)^2*sin(τ)^2*sin(π*Γ/λ)^2

"""
  Transmission degrees for orthogonal analyser and polarizer
Reference: Bloss, F.D. (1999): Optical crystallography.
           Mineralogical Societyof America, Washington, DC
"""
L_orthogonal(λ, Γ) = sin(π*Γ/λ)^2

"Spectral transmission matrix"
Iλ(λ_vector, Γ_vector) = [L_orthogonal(λ,Γ) for λ in λ_vector, Γ in Γ_vector]
