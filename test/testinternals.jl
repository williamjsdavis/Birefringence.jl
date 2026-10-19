"Testing internal (non-exported) functions"
function test_internals(λ_array, Γ_array)
    λ_collect = collect(λ_array)
    Γ_collect = collect(Γ_array)
    λ_downsample = λ_collect[1:2:end]
    λ_length = length(λ_array)
    Γ_length = length(Γ_array)

    @testset "Utilities" begin
        x = 0:0.0001:2.5
        int_test = Birefringence.integrate(x,sin.(x))
        @test int_test ≈ (1.0 - cos(2.5))
    end

    @testset "Color matching functions" begin
        color_matching_range = Birefringence.CIE_standard(λ_array)
        color_matching_collect = Birefringence.CIE_standard(λ_collect)
        @test size(color_matching_range) == (3, λ_length)
        @test size(color_matching_collect) == (3, λ_length)
        @test all(color_matching_range .≈ color_matching_collect)
        # Equal-energy white has chromaticity (1/3, 1/3)
        XYZ_E = vec(sum(Birefringence.CIE_standard(360:1:830), dims=2))
        @test isapprox(XYZ_E[1:2] ./ sum(XYZ_E), [1/3, 1/3], atol=1e-3)
    end

    @testset "Physics" begin
        Iλ_ranges = Birefringence.Iλ(λ_array, Γ_array)
        Iλ_range_collect = Birefringence.Iλ(λ_array, Γ_collect)
        Iλ_collect_range = Birefringence.Iλ(λ_collect, Γ_array)
        Iλ_collects = Birefringence.Iλ(λ_collect, Γ_collect)
        @test size(Iλ_ranges) == (λ_length, Γ_length)
        @test size(Iλ_range_collect) == (λ_length, Γ_length)
        @test size(Iλ_collect_range) == (λ_length, Γ_length)
        @test size(Iλ_collects) == (λ_length, Γ_length)
        @test all(Iλ_ranges .≈ Iλ_range_collect)
        @test all(Iλ_ranges .≈ Iλ_collect_range)
        @test all(Iλ_ranges .≈ Iλ_collects)
    end

    @testset "Tristimulus XYZ values" begin
        XYZ_ranges = Birefringence.L_XYZ(λ_array, Γ_array)
        XYZ_range_collect = Birefringence.L_XYZ(λ_array, Γ_collect)
        XYZ_collect_range = Birefringence.L_XYZ(λ_collect, Γ_array)
        XYZ_collects = Birefringence.L_XYZ(λ_collect, Γ_collect)
        XYZ_downsample = Birefringence.L_XYZ(λ_downsample, Γ_collect)
        @test size(XYZ_ranges) == (3, Γ_length)
        @test size(XYZ_range_collect) == (3, Γ_length)
        @test size(XYZ_collect_range) == (3, Γ_length)
        @test size(XYZ_collects) == (3, Γ_length)
        @test all(XYZ_ranges .≈ XYZ_range_collect)
        @test isapprox(XYZ_ranges, XYZ_collect_range, atol=1e-5)
        @test isapprox(XYZ_ranges, XYZ_collects, atol=1e-5)
        @test isapprox(XYZ_ranges, XYZ_downsample, atol=1e-5)
    end

    @testset "Illuminants" begin
        B = Birefringence
        # D65 table values, and linear interpolation between them
        @test B.spd(D65(), 560.0) == 100.0
        @test B.spd(D65(), 400.0) == 82.7549
        @test B.spd(D65(), 562.5) ≈ (B.spd(D65(), 560.0) + B.spd(D65(), 565.0)) / 2
        @test B.spd(D65(), 830.0) == 60.3125
        @test_throws DomainError B.spd(D65(), 850.0)
        @test B.spd(IlluminantE(), 500.0) == 1.0
        @test B.spd(IlluminantA(), 560.0) ≈ 100.0
        # Illuminant A is a blackbody at ≈ 2856 K
        λ = 380.0:5.0:780.0
        A = B.spd.(Ref(IlluminantA()), λ) ./ B.spd(IlluminantA(), 560.0)
        P = B.spd.(Ref(Blackbody(2856)), λ) ./ B.spd(Blackbody(2856), 560.0)
        @test isapprox(A, P, rtol=2e-3)
        @test_throws AssertionError Blackbody(-1)
        # Computed white points match published chromaticities
        λ_fine = 360.0:1.0:830.0
        for (ill, xy, tol) in ((D65(), [0.3127, 0.3290], 1e-3),
                               (IlluminantE(), [1/3, 1/3], 1e-3),
                               (IlluminantA(), [0.4476, 0.4074], 2e-3))
            w = B.white_XYZ(λ_fine, ill)
            @test w[2] ≈ 1.0
            @test isapprox(B.xyY(reshape(w, 3, 1))[1:2], xy, atol=tol)
        end
        @test B.xyY([1.0 2.0; 1.0 2.0; 1.0 2.0]) ≈ [1/3 1/3; 1/3 1/3; 1.0 2.0]
        # Quadrature weights integrate a constant exactly on irregular grids
        @test sum(B.quadrature_weights([380.0, 381.0, 385.0, 400.0])) ≈ 20.0
    end

    @testset "White balance" begin
        B = Birefringence
        w_A = B.white_XYZ(380.0:5.0:780.0, IlluminantA())
        M = B.bradford_matrix(w_A, B.D65_WHITE)
        @test M * w_A ≈ B.D65_WHITE
        @test B.bradford_matrix(B.D65_WHITE, B.D65_WHITE) ≈ [1 0 0; 0 1 0; 0 0 1]
        # Crossed polarisers never transmit more than the light source
        @test all(B.L_XYZ(λ_array, Γ_array)[2,:] .<= 1.0)
    end

    RGB_ranges = Birefringence.XYZ_to_RGB(Birefringence.L_XYZ(λ_array, Γ_array))
    RGB_range_collect = Birefringence.XYZ_to_RGB(Birefringence.L_XYZ(λ_array, Γ_collect))
    RGB_collect_range = Birefringence.XYZ_to_RGB(Birefringence.L_XYZ(λ_collect, Γ_collect))
    RGB_collects = Birefringence.XYZ_to_RGB(Birefringence.L_XYZ(λ_collect, Γ_array))
    RGB_downsample = Birefringence.XYZ_to_RGB(Birefringence.L_XYZ(λ_downsample, Γ_collect))
    RGB_clip_sample = Birefringence.clamp_RGB(RGB_ranges)
    RGB_γ_sample = Birefringence.RGB_γ_correction(RGB_clip_sample)
    RGB_array = Birefringence.RGB_typearray(RGB_γ_sample)
    @testset "RGB" begin
        @test size(RGB_ranges) == (3, Γ_length)
        @test size(RGB_range_collect) == (3, Γ_length)
        @test size(RGB_collect_range) == (3, Γ_length)
        @test size(RGB_collects) == (3, Γ_length)
        @test all(RGB_ranges .≈ RGB_range_collect)
        @test isapprox(RGB_ranges, RGB_collect_range, atol=1e-5)
        @test isapprox(RGB_ranges, RGB_collects, atol=1e-5)
        @test isapprox(RGB_ranges, RGB_downsample, atol=1e-5)
        @test size(RGB_array) == (Γ_length,)
        # RGB matrices map the D65 white point to (1,1,1)
        D65_white = [0.95047, 1.0, 1.08883]
        @test isapprox(Birefringence.MRGB_ADOBE * D65_white, ones(3), atol=1e-3)
        @test isapprox(Birefringence.MRGB_SRGB * D65_white, ones(3), atol=1e-3)
    end

    @testset "Transfer functions" begin
        for cs in (AdobeRGB(), sRGB())
            @test Birefringence.encode(0.0, cs) == 0.0
            @test Birefringence.encode(1.0, cs) ≈ 1.0
            x = 0:0.001:1
            @test issorted(Birefringence.encode.(x, Ref(cs)))
        end
        # sRGB piecewise function is continuous at the breakpoint
        @test isapprox(12.92 * 0.0031308,
                       1.055 * 0.0031308^(1/2.4) - 0.055, atol=1e-6)
        # Adobe RGB gamma is 563/256 ≈ 2.2
        @test Birefringence.encode(0.5, AdobeRGB()) ≈ 0.5^(256/563)
    end
    return RGB_array
end
