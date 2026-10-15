using Birefringence
using Test
include("testinternals.jl")

const λ_array = 360:0.1:830
const Γ_array = 0:20:2500

λ_length = length(λ_array)
Γ_length = length(Γ_array)

# Internal functions
RGB_array = test_internals(λ_array, Γ_array)

# Wrapped functions
RGB_default = birefringence_array(Γ_array)
RGB_wrapped = birefringence_array(Γ_array, λ=λ_array, γ=0.5)
RGB_adobe = birefringence_array(Γ_array, colorspace=AdobeRGB())
RGB_srgb = birefringence_array(Γ_array, colorspace=sRGB())
RGB_linear = birefringence_array(Γ_array, colorspace=sRGB(), γ=1)
@testset "RGB wrapped" begin
    @test size(RGB_default) == (Γ_length,)
    @test size(RGB_wrapped) == (Γ_length,)
    @test all(RGB_wrapped .== RGB_array)
    @test all(RGB_default .== RGB_adobe)
    @test size(RGB_srgb) == (Γ_length,)
    @test RGB_srgb != RGB_adobe
    # Zero path difference is black in every color space
    @test RGB_srgb[1] == Birefringence.RGB(0.0, 0.0, 0.0)
    # Encoding brightens: encoded values are ≥ linear values
    @test all(c -> 0 <= c <= 1, reinterpret(Float64, RGB_srgb))
    @test all(reinterpret(Float64, RGB_srgb) .>= reinterpret(Float64, RGB_linear) .- 1e-12)
end
