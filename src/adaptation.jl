# Chromatic adaptation (white balance)

const M_BRADFORD = [ 0.8951  0.2664 -0.1614;
                    -0.7502  1.7135  0.0367;
                     0.0389 -0.0685  1.0296]

"""
Bradford chromatic adaptation matrix, mapping colors seen under a light source
with white `src_white` to the corresponding colors under `dst_white` (both CIE
XYZ). This is the adaptation the eye makes, and that white balance makes in a
camera.

Reference: http://www.brucelindbloom.com/Eqn_ChromAdapt.html
"""
function bradford_matrix(src_white, dst_white)
    ρ_src = M_BRADFORD * src_white
    ρ_dst = M_BRADFORD * dst_white
    return inv(M_BRADFORD) * Diagonal(ρ_dst ./ ρ_src) * M_BRADFORD
end
