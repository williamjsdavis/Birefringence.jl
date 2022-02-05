using Birefringence
#using Plots

const λ_vector = 360:0.1:830
const Γ_vector = 0:10:2500

RGB_sample = XYZ_to_RGB(λ_vector, Γ_vector)
RGB_clip_sample = clamp_RGB(RGB_sample)
RGB_array = RGB_typearray(RGB_clip_sample)

display(RGB_array)
birefringence_array(Γ_vector)
birefringence_array(Γ_vector, vision=Protanopia())
birefringence_array(Γ_vector, vision=Deuteranopia())
birefringence_array(Γ_vector, vision=Tritanopia())
