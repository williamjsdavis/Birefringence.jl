# Settings that reproduce published charts

"""
Settings reproducing the chart of Sørensen (2013), for use as
`birefringence_array(Γ; sorensen2013()...)`.

The paper computes colors without a light source spectrum (equivalent to
equal-energy light) and without white balance, scales luminance by 1/100,
converts to Adobe RGB, clips to [0,1] and applies a gamma of 0.5 for contrast.

Two small differences remain, together invisible (mean CIEDE2000 ≈ 0.15):
the package uses analytic approximations of the CIE 1931 color matching
functions instead of the tabulated ones, and the corrected Adobe RGB matrix
(the paper prints 2.04414 for 2.0414).

Reference: Sørensen, B.E. (2013): A revised Michel-Lévy interference colour
chart based on first-principles calculations. Eur. J. Mineral. 25, 5–10.
https://doi.org/10.1127/0935-1221/2013/0025-2252
"""
function sorensen2013()
    λ = 360.0:1.0:830.0
    # The paper's 1/100 scale, relative to this package's normalisation (Y = 1
    # for full transmission): full transmission has Y = ∫ȳ(λ)dλ / 100 ≈ 1.07
    brightness = sum(CIE_standard(λ)[2,:] .* quadrature_weights(λ)) / 100
    return (λ=λ, illuminant=IlluminantE(), white_balance=false,
            brightness=brightness, colorspace=AdobeRGB(), γ=0.5)
end
