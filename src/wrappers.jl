"""
Calculate birefringenge colors

Parameters:
Γ => Path differences in nm, array

Optional parameters:
λ => Wavelength integration grid, nm
gamma => Non-linear contrast correction, [0,1]
vision => Standard or color deficiency type
"""
function birefringence_array(
    Γ;
    λ=380.0:5.0:780.0,
    γ=0.5,
    vision::Vision=Standard(),
)
    RGB_raw = XYZ_to_RGB(λ, Γ)
    RGB_clip = clamp_RGB(RGB_raw)
    RGB_γ_corrected = RGB_γ_correction(RGB_clip, γ)
    RGBtype_array = RGB_typearray(RGB_γ_corrected)
    return visualise(RGBtype_array, vision)
end
