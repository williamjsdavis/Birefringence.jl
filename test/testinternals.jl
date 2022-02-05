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

    RGB_ranges = Birefringence.XYZ_to_RGB(λ_array, Γ_array)
    RGB_range_collect = Birefringence.XYZ_to_RGB(λ_array, Γ_collect)
    RGB_collect_range = Birefringence.XYZ_to_RGB(λ_collect, Γ_collect)
    RGB_collects = Birefringence.XYZ_to_RGB(λ_collect, Γ_array)
    RGB_downsample = Birefringence.XYZ_to_RGB(λ_downsample, Γ_collect)
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
    end
    return RGB_array
end
