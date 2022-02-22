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

`gamma` => Non-linear contrast correction, [0,1]

`vision` => Standard or color deficiency type

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

# References

Bjørn Eske Sørensen; A revised Michel-Lévy interference colour chart based on first-principles calculations. European Journal of Mineralogy 2012;; 25 (1): 5–10. doi: https://doi.org/10.1127/0935-1221/2013/0025-2252
