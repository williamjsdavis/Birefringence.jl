# Conversion from CIE XYZ tristimulus values to displayable colors

"""
RGB color space that the output colors are expressed in. Both color spaces
supported here use a D65 white point.

Supported: `AdobeRGB()`, `sRGB()`
"""
abstract type RGBColorSpace end

"""
Adobe RGB (1998). Wider gamut than sRGB, particularly in greens.

Reference: Pascale, D., 2003, A review of RGB color spaces
http://www.babelcolor.com/download/A%20review%20of%20RGB%20color%20spaces.pdf
"""
struct AdobeRGB <: RGBColorSpace end

"""
sRGB (IEC 61966-2-1). The default color space of most cameras, displays,
image files and software.

Reference: https://en.wikipedia.org/wiki/SRGB
"""
struct sRGB <: RGBColorSpace end

const MRGB_ADOBE = [ 2.0414 -0.5649 -0.3447;
                    -0.9693   1.8760  0.0416;
                     0.0134  -0.1184  1.0154]

const MRGB_SRGB = [ 3.2406 -1.5372 -0.4986;
                   -0.9689   1.8758  0.0415;
                    0.0557  -0.2040  1.0570]

"XYZ to linear RGB conversion matrix"
XYZ_to_RGB_matrix(::AdobeRGB) = MRGB_ADOBE
XYZ_to_RGB_matrix(::sRGB) = MRGB_SRGB

"CIE XYZ tristimulus values to linear RGB"
XYZ_to_RGB(λ_vector, Γ_vector, colorspace::RGBColorSpace=AdobeRGB()) =
    XYZ_to_RGB_matrix(colorspace) * L_XYZ(λ_vector, Γ_vector)

"Clamp RGB to (0,1), no gamma"
clamp_RGB(x) = clamp.(x,0,1)

"Standard transfer function (gamma encoding) of each color space, for x in (0,1)"
encode(x, ::AdobeRGB) = x^(256/563)
encode(x, ::sRGB) = x <= 0.0031308 ? 12.92x : 1.055x^(1/2.4) - 0.055

encode_RGB(x, colorspace::RGBColorSpace) = encode.(x, Ref(colorspace))

"Simple power law gamma correction, x^γ"
RGB_γ_correction(x, γ=0.5) = x.^γ

to_RGB(i) = RGB(i[1], i[2], i[3])
RGB_typearray(RGBarray) = map(to_RGB, eachcol(RGBarray))::Array{RGB{Float64},1}
