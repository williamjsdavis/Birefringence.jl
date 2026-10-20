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
RGB_wrapped = birefringence_array(Γ_array, λ=λ_array, white_balance=false, γ=0.5)
RGB_adobe = birefringence_array(Γ_array, colorspace=AdobeRGB())
RGB_srgb = birefringence_array(Γ_array, colorspace=sRGB())
RGB_linear = birefringence_array(Γ_array, colorspace=sRGB(), γ=1)
@testset "RGB wrapped" begin
    @test size(RGB_default) == (Γ_length,)
    @test size(RGB_wrapped) == (Γ_length,)
    @test all(RGB_wrapped .== RGB_array)
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

f(a) = reinterpret(Float64, a)
@testset "Light source and brightness" begin
    # Very high orders average to a neutral grey (half the light transmitted)
    for ill in (D65(), IlluminantE(), IlluminantA(), Blackbody(3200))
        c = birefringence_array([20000.0], λ=360.0:1.0:830.0, illuminant=ill)[1]
        @test isapprox(c.r, c.g, atol=0.01) && isapprox(c.g, c.b, atol=0.01)
        @test isapprox(c.g, Birefringence.encode(0.5, sRGB()), atol=0.01)
    end
    # Without white balance, a tungsten lamp gives an orange cast
    c = birefringence_array([20000.0], λ=360.0:1.0:830.0,
                            illuminant=IlluminantA(), white_balance=false)[1]
    @test c.r > c.g > c.b
    # D65 needs (almost) no white balance with D65-based color spaces
    @test isapprox(f(birefringence_array(Γ_array)),
                   f(birefringence_array(Γ_array, white_balance=false)), atol=0.01)
    # Brightness scales linear RGB, before clipping
    lin(b) = f(birefringence_array(Γ_array, brightness=b, γ=1))
    unclipped = (lin(0.5) .< 0.5) .& (lin(0.5) .> 0)
    @test lin(0.25)[unclipped] ≈ lin(0.5)[unclipped] ./ 2
    @test all(lin(0.0) .== 0)
end

@testset "Sørensen (2013) settings" begin
    s = sorensen2013()
    @test s.illuminant == IlluminantE()
    @test s.white_balance == false
    @test s.colorspace == AdobeRGB()
    @test s.γ == 0.5
    @test isapprox(s.brightness, 1.069, atol=1e-3)
    # Peaks of linear RGB before clipping, as in Fig. 2 of the paper
    Γ = 0.0:1.0:2500.0
    lin = s.brightness * Birefringence.XYZ_to_RGB(
        Birefringence.L_XYZ(s.λ, Γ, s.illuminant), s.colorspace)
    for (channel, Γ_range, peak, Γ_peak) in ((1, 250:350, 1.21, 306),
                                             (1, 850:1000, 1.22, 918),
                                             (1, 1450:1550, 1.19, 1506),
                                             (1, 2050:2150, 1.01, 2091),
                                             (2, 230:320, 1.02, 273),
                                             (3, 180:260, 0.98, 222))
        v, i = findmax(lin[channel, Γ_range .+ 1])
        @test isapprox(v, peak, atol=0.01)
        @test abs(Γ_range[i] - Γ_peak) <= 2
    end
    # Settings can be combined with, and overridden by, other keywords
    @test birefringence_array(Γ_array; sorensen2013()..., vision=Protanopia()) !=
          birefringence_array(Γ_array; sorensen2013()...)
    @test birefringence_array(Γ_array; sorensen2013()..., colorspace=sRGB()) !=
          birefringence_array(Γ_array; sorensen2013()...)
end

@testset "XYZ output" begin
    XYZ = birefringence_XYZ(Γ_array)
    @test size(XYZ) == (3, Γ_length)
    @test XYZ[:, 1] == zeros(3)
    # Converting the XYZ output gives the RGB output, before clipping
    lin = Birefringence.XYZ_to_RGB(XYZ, sRGB())
    unclipped = vec(all(0 .<= lin .<= 1, dims=1))
    @test f(birefringence_array(Γ_array, γ=1))[repeat(unclipped, inner=3)] ≈ vec(lin[:, unclipped])
    # Keywords are passed through
    @test birefringence_XYZ(Γ_array, brightness=0.5) ≈ 0.5 .* XYZ
    @test birefringence_XYZ(Γ_array, illuminant=IlluminantA()) != XYZ
    # Values are not clipped
    @test any(Birefringence.XYZ_to_RGB(XYZ, sRGB()) .< 0)
end
