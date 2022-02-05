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
RGB_wrapped = birefringence_array(Γ_array, λ=λ_array)
@testset "RGB wrapped" begin
    @test size(RGB_default) == (Γ_length,)
    @test size(RGB_wrapped) == (Γ_length,)
    @test all(RGB_wrapped .== RGB_array)
end
