using Birefringence
using Test
include("testinternals.jl")

const λ_array = 360:0.1:830
const Γ_array = 0:20:2500

λ_length = length(λ_array)
Γ_length = length(Γ_array)

# Internal functions
RGB_array, RGB_legacy_internal = test_internals(λ_array, Γ_array)

# Wrapped functions
RGB_default = birefringence_array(Γ_array)
RGB_wrapped = birefringence_array(Γ_array, λ=λ_array, γ=0.5)
RGB_legacy = birefringence_array(Γ_array, λ=λ_array, colorspace=AdobeRGB(), γ=0.5)
RGB_adobe = birefringence_array(Γ_array, colorspace=AdobeRGB())
RGB_srgb = birefringence_array(Γ_array, colorspace=sRGB())
RGB_linear = birefringence_array(Γ_array, colorspace=sRGB(), γ=1)
@testset "RGB wrapped" begin
    @test size(RGB_default) == (Γ_length,)
    @test size(RGB_wrapped) == (Γ_length,)
    @test all(RGB_wrapped .== RGB_array)
    # Adobe RGB with γ=0.5 reproduces pre-v0.2.0 output
    @test all(RGB_legacy .== RGB_legacy_internal)
    @test all(RGB_default .== RGB_srgb)
    @test size(RGB_srgb) == (Γ_length,)
    @test RGB_srgb != RGB_adobe
    # Integer wavelength grids work and match float grids
    @test birefringence_array(Γ_array, λ=380:5:780) == birefringence_array(Γ_array, λ=380.0:5.0:780.0)
    # Zero path difference is black in every color space
    @test RGB_srgb[1] == Birefringence.RGB(0.0, 0.0, 0.0)
    # Encoding brightens: encoded values are ≥ linear values
    @test all(c -> 0 <= c <= 1, reinterpret(Float64, RGB_srgb))
    @test all(reinterpret(Float64, RGB_srgb) .>= reinterpret(Float64, RGB_linear) .- 1e-12)
end
