# Birefringence.jl
A computational calculation of the revised Michel-Lévy interference colour chart, based on Sørensen (2013). The default settings give physically accurate colors for comparison with photographs; the published chart can be reproduced with `sorensen2013()` (see below)

<img width="1035" alt="Screen Shot 2022-01-18 at 10 23 30" src="https://user-images.githubusercontent.com/38541020/150920010-4e668a3c-7c0c-4d3f-8ab7-4f661f020844.png">

# How to use

<img width="645" alt="Screen Shot 2022-01-31 at 10 36 43" src="https://user-images.githubusercontent.com/38541020/152619415-65931884-1e12-4597-a2bc-88e126aacede.png">

Include the package with `using Birefringence`. The Michel-Lévy interference colour chart can be created using the function `birefringence_array(...)`.

## Parameters
`Γ` => Path differences in nm, array

Optional parameters:

`λ` => Wavelength integration grid, nm. Default `380.0:5.0:780.0`

`illuminant` => Light source, `D65()` (default), `IlluminantE()`, `IlluminantA()` or `Blackbody(T)`. See below

`white_balance` => If `true` (default), colors are adapted so that the light source looks white, as the eye and cameras do. See below

`brightness` => Luminance scale. With `1` (default), a sample transmitting all light is displayed as full white. See below

`colorspace` => Output RGB color space, `sRGB()` (default) or `AdobeRGB()`. See below

`γ` => Gamma encoding. `nothing` (default) uses the color space's standard transfer function. A number in [0,1] applies a simple power law `x^γ` instead, and `γ=1` gives linear RGB

`vision` => Standard or color deficiency type

## Choosing an output color space

RGB values only have a meaning relative to a color space: the same physical color has different R, G, B numbers in sRGB and in Adobe RGB. The package first calculates device-independent CIE XYZ colors, then converts them into the RGB color space you choose. If you use the RGB values outside this package (e.g., to compare with photographs, or to plot in other software), choose the color space deliberately:

- `sRGB()` (default): use this unless you know you need something else. It is the default for most cameras, displays, image files and software, which will assume RGB values are sRGB
- `AdobeRGB()`: wider range of colors than sRGB, particularly greens. Use it only if your images or software are explicitly set up for Adobe RGB. This was the color space used before v0.2.0

Both color spaces use a D65 white point.

Many interference colors, particularly the saturated colors of the second and third orders, are outside the range of colors that sRGB can show. These colors are clipped to the nearest values that sRGB can display (each of R, G, B is clipped to [0,1]), which slightly changes their hue and saturation. With the default settings, about half of path differences between 0 and 1600 nm are clipped by some amount. Adobe RGB clips about a quarter of them, and only slightly (by at most 3%).

To compare colors (e.g., to find the path difference that best matches a color in a photograph), measure the distance between colors in a perceptual color space such as CIELAB rather than comparing RGB values directly.

```julia
using Birefringence
Γ = 0:1:1600
colors = birefringence_array(Γ)  # sRGB by default
```

## Light source, white balance and brightness

The colors depend on the spectrum of the light that illuminates the sample. The defaults model a sample viewed in daylight, by an eye or camera that has adapted to that light:

`illuminant` sets the light source's spectrum:
- `D65()` (default): CIE standard daylight, ≈ 6500 K. This is the standard light source for colorimetry, and the white point of sRGB and Adobe RGB. It is also the light source used by the [interfr](https://cran.r-project.org/package=interfr) R package, which implements Sørensen's chart
- `IlluminantE()`: equal energy at all wavelengths. A theoretical light source, used by versions of this package before v0.3.0
- `IlluminantA()`: CIE standard tungsten lamp, ≈ 2856 K
- `Blackbody(T)`: a Planckian radiator at temperature `T` in Kelvin. For example, `Blackbody(3200)` for a typical microscope halogen lamp

LED light sources, and filters in the light path (such as a microscope's blue daylight filter), are not modelled.

`white_balance` (default `true`) adapts the colors so that the light source itself appears white (using the Bradford transform to the color space's D65 white point). This is what the eye does, and what a camera's white balance does. With white balance, the light source only changes the interference colors themselves; without it, the whole chart takes on the color of the light, e.g. orange for a tungsten lamp. With `D65()` and the D65-based color spaces, white balance has almost no effect.

`brightness` (default `1`) scales the luminance of all colors. With `1`, the light source itself (full transmission, as with parallel polarisers and no sample) is displayed as full white. Between crossed polarisers no color is brighter than this, so the default never over-exposes: the brightest interference color, the first-order white at Γ ≈ 275 nm, has a luminance of 0.99. High orders average to half the light, a neutral grey. Values below `1` darken the chart, as a dimmer lamp or shorter camera exposure would.

How much do these choices matter? Differences relative to the defaults, over Γ = 0 to 1600 nm, measured with CIEDE2000 (ΔE₀₀ ≈ 1 is about the smallest difference visible side by side, and ΔE₀₀ > 10 is a clearly different color):

| Setting | Mean ΔE₀₀ | Max ΔE₀₀ |
|---|---|---|
| `illuminant=IlluminantE()` | 0.8 | 2.1 |
| `illuminant=Blackbody(3200)` | 3.2 | 12.0 |
| `illuminant=IlluminantA()` | 4.0 | 15.2 |
| `illuminant=IlluminantE(), white_balance=false` | 3.3 | 12.4 |
| `illuminant=IlluminantA(), white_balance=false` | 19.7 | 35.8 |
| `brightness=0.8` | 4.7 | 6.0 |

In summary: the choice between daylight and equal-energy light hardly matters, but if you are matching photographs taken under a halogen or tungsten lamp, use `Blackbody(T)` or `IlluminantA()`, with white balance on if the camera's white balance was set for that lamp. The largest differences are in the second and third orders.

```julia
# A microscope with a 3200 K halogen lamp, photographed with white balance
colors = birefringence_array(Γ, illuminant=Blackbody(3200))
```

## Reproducing the chart of Sørensen (2013)

The default settings aim for physically accurate colors that can be compared with photographs (daylight, white balance, sRGB). They differ from the published chart of Sørensen (2013) by mean ΔE₀₀ = 4.2 for Γ = 0 to 1600 nm, with the largest differences in the first order (max 11.7, at Γ ≈ 220 nm). To reproduce the published chart, use the settings from the paper:

```julia
colors = birefringence_array(Γ; sorensen2013()...)
```

These are: wavelengths 360 to 830 nm, no light source spectrum (equivalent to `IlluminantE()`), no white balance, luminance scaled by 1/100 (`brightness ≈ 1.07`), Adobe RGB, and a gamma of 0.5 for contrast. Individual settings can be overridden, e.g. `birefringence_array(Γ; sorensen2013()..., vision=Protanopia())`.

The result matches the paper's method to within mean ΔE₀₀ = 0.15 (max 0.71), which is not visible. The remaining differences are that this package uses analytic approximations of the CIE 1931 color matching functions rather than the tabulated values, and the corrected Adobe RGB matrix (the paper prints 2.04414 for 2.0414). Note that the paper's RGB values are Adobe RGB with a gamma of 0.5, but are displayed by most software as if they were sRGB.

## CIE XYZ output

`birefringence_XYZ(Γ; ...)` returns the colors as CIE 1931 XYZ, before conversion to RGB and so without clipping, with the same `λ`, `illuminant`, `white_balance` and `brightness` options. Use it to convert to other color spaces, e.g. CIELAB to compare colors.

## Examples

[`examples/`](examples) has a table of interference colors from 0 to 1600 nm, as RGB (both the published chart and physically based sRGB), CIE XYZ and CIELAB, and the script that makes it.

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
- v0.3.0 Added `illuminant` (`D65()`, `IlluminantE()`, `IlluminantA()`, `Blackbody(T)`), `white_balance` and `brightness` options. Default light source is now D65 daylight (previously equal energy), with white balance. Colors are now normalised so that full transmission has luminance 1, replacing the 1/100 scale factor of Sørensen (2013). Added `sorensen2013()` settings to reproduce the published chart. Fixed the `xyY` function
- v0.4.0 Added `birefringence_XYZ` for CIE XYZ output without clipping. Added `examples/` with a table of interference colors from 0 to 1600 nm

# References

Bjørn Eske Sørensen; A revised Michel-Lévy interference colour chart based on first-principles calculations. European Journal of Mineralogy 2013; 25 (1): 5–10. doi: https://doi.org/10.1127/0935-1221/2013/0025-2252
