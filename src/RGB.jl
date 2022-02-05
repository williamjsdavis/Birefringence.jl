# Conversion from CIE XYZ tristimulus values to displayable colors

const MRGB = [ 2.04414 -0.5649 -0.3447;
              -0.9693   1.8760  0.0416;
               0.0134  -0.1184  1.0154]

"""
CIE XYZ tristimulus values to Adobe RGB

Reference: Pascale, D., 2003, A review of RGB color spaces
http://www.babelcolor.com/download/A%20review%20of%20RGB%20color%20spaces.pdf
"""
XYZ_to_RGB(λ_vector, Γ_vector) = MRGB * L_XYZ(λ_vector, Γ_vector)

"Clamp RGB to (0,1), no gamma"
clamp_RGB(x) = clamp.(x,0,1)

RGB_γ_correction(x, γ=0.5) = x.^γ

to_RGB(i) = RGB(i[1], i[2], i[3])
RGB_typearray(RGBarray) = map(to_RGB, eachcol(RGBarray))::Array{RGB{Float64},1}
