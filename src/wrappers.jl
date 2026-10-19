"""
Calculate birefringenge colors

Parameters:
Γ => Path differences in nm, array

Optional parameters:
λ => Wavelength integration grid, nm
colorspace => Output RGB color space, `sRGB()` (default) or `AdobeRGB()`
γ => Gamma encoding. `nothing` (default) uses the color space's standard
     transfer function; a number in [0,1] applies a simple power law x^γ
     instead (γ=1 gives linear RGB)
vision => Standard or color deficiency type
"""
function birefringence_array(
    Γ;
    λ=380.0:5.0:780.0,
    colorspace::RGBColorSpace=sRGB(),
    γ=nothing,
    vision::Vision=Standard(),
)
    RGB_raw = XYZ_to_RGB(λ, Γ, colorspace)
    RGB_clip = clamp_RGB(RGB_raw)
    RGB_encoded = isnothing(γ) ? encode_RGB(RGB_clip, colorspace) :
                                 RGB_γ_correction(RGB_clip, γ)
    RGBtype_array = RGB_typearray(RGB_encoded)
    return visualise(RGBtype_array, vision)
end
