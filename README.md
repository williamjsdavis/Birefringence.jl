# Birefringence.jl
A computational calculation of the revised Michel-Lévy interference colour chart, based on Sørensen (2012)

<img width="1035" alt="Screen Shot 2022-01-18 at 10 23 30" src="https://user-images.githubusercontent.com/38541020/150920010-4e668a3c-7c0c-4d3f-8ab7-4f661f020844.png">

# How to use

<img width="645" alt="Screen Shot 2022-01-31 at 10 36 43" src="https://user-images.githubusercontent.com/38541020/152619415-65931884-1e12-4597-a2bc-88e126aacede.png">

Include the package with `using Birefringence`. The Michel-Lévy interference colour chart can be created using the function `birefringence_array(...)`.

## Parameters
`Γ` => Path differences in nm, array

Optional parameters:

`λ` => Wavelength integration grid, nm

`colorspace` => Output RGB color space, `sRGB()` (default) or `AdobeRGB()`. See below

`γ` => Gamma encoding. `nothing` (default) uses the color space's standard transfer function. A number in [0,1] applies a simple power law `x^γ` instead, and `γ=1` gives linear RGB

`vision` => Standard or color deficiency type

## Choosing an output color space

RGB values only have a meaning relative to a color space: the same physical color has different R, G, B numbers in sRGB and in Adobe RGB. The package first calculates device-independent CIE XYZ colors, then converts them into the RGB color space you choose. If you use the RGB values outside this package (e.g., to compare with photographs, or to plot in other software), choose the color space deliberately:

- `sRGB()` (default): use this unless you know you need something else. It is the default for most cameras, displays, image files and software, which will assume RGB values are sRGB
- `AdobeRGB()`: wider range of colors than sRGB, particularly greens. Use it only if your images or software are explicitly set up for Adobe RGB. This was the color space used before v0.2.0

Both color spaces use a D65 white point. Colors outside the chosen color space's range are clipped to it. To compare colors (e.g., to find the path difference that best matches a color in a photograph), measure the distance between colors in a perceptual color space such as CIELAB rather than comparing RGB values directly.

```julia
using Birefringence
Γ = 0:1:1600
colors = birefringence_array(Γ)  # sRGB by default
```

## Types of vision supported

- `Standard()`
- `Protanopia()`
- `Deuteranopia()`
- `Tritanopia()`
- `Protanomaly(p)`
- `Deuteranomaly(p)`
- `Tritanomaly(p)`

... where `p` is a value between 0 and 1, where 1 is complete loss of that cone sensitivity, and 0 is no loss in sensitivity.

# Version log
- v0.1.0 First release, basic functionality
- v0.1.1 Regenerated Manifest for current Julia (old manifest failed to load); added [compat] bounds, requires Julia 1.10+
- v0.1.2 Fixed typo in the XYZ to Adobe RGB conversion matrix (red channel was ~0.3% too high)
- v0.2.0 Added `colorspace` option (`sRGB()`, `AdobeRGB()`). Default output is now sRGB (previously Adobe RGB), and gamma encoding defaults to each color space's standard transfer function instead of `x^0.5`. Pass `colorspace=AdobeRGB(), γ=0.5` to reproduce earlier output
- v0.2.1 Fixed typo in the ȳ color matching function (left width 49.9 nm, should be 46.9 nm), which shifted all colors slightly towards green. Fixed crash when the wavelength grid `λ` uses integers

# References

Bjørn Eske Sørensen; A revised Michel-Lévy interference colour chart based on first-principles calculations. European Journal of Mineralogy 2012;; 25 (1): 5–10. doi: https://doi.org/10.1127/0935-1221/2013/0025-2252
