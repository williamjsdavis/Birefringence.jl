"""
Calculate birefringenge colors

Parameters:
Γ => Path differences in nm, array

Optional parameters:
λ => Wavelength integration grid, nm
illuminant => Light source, `D65()` (default), `IlluminantE()`,
              `IlluminantA()` or `Blackbody(T)`
white_balance => If `true` (default), adapt colors so that the light source
                 appears white, as the eye and cameras do
brightness => Luminance scale. With `1` (default), a sample transmitting all
              light (Y = 1) is displayed as full white
colorspace => Output RGB color space, `sRGB()` (default) or `AdobeRGB()`
γ => Gamma encoding. `nothing` (default) uses the color space's standard
     transfer function; a number in [0,1] applies a simple power law x^γ
     instead (γ=1 gives linear RGB)
vision => Standard or color deficiency type
"""
function birefringence_array(
    Γ;
    λ=380.0:5.0:780.0,
    illuminant::Illuminant=D65(),
    white_balance::Bool=true,
    brightness::Real=1.0,
    colorspace::RGBColorSpace=sRGB(),
    γ=nothing,
    vision::Vision=Standard(),
)
    XYZ = brightness * L_XYZ(λ, Γ, illuminant)
    if white_balance
        XYZ = bradford_matrix(white_XYZ(λ, illuminant), whitepoint(colorspace)) * XYZ
    end
    RGB_raw = XYZ_to_RGB(XYZ, colorspace)
    RGB_clip = clamp_RGB(RGB_raw)
    RGB_encoded = isnothing(γ) ? encode_RGB(RGB_clip, colorspace) :
                                 RGB_γ_correction(RGB_clip, γ)
    RGBtype_array = RGB_typearray(RGB_encoded)
    return visualise(RGBtype_array, vision)
end
