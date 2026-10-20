# Michel-Lévy interference colours as a table, for path differences 0 to 1600 nm
#
# Writes michel_levy_0-1600nm.csv and michel_levy_0-1600nm.png next to this
# script. Run from the repository root with:
#
#     julia --project=. examples/michel_levy_table.jl
#
# See examples/README.md for a description of the columns.

ENV["GKSwstype"] = "100"  # Plot without opening a window
using Birefringence
using Images: RGB, XYZ, Lab, colordiff, DE_2000
using Plots
using Printf

Γ = 0:1:1600
to255(c) = round.(Int, 255 .* (c.r, c.g, c.b))

# The published chart of Sørensen (2013)
sorensen = birefringence_array(Γ; sorensen2013()...)

# Physically based colors: daylight (D65), white balanced, sRGB
srgb = birefringence_array(Γ)
XYZ_true = [XYZ(c...) for c in eachcol(birefringence_XYZ(Γ))]
Lab_true = convert.(Lab, XYZ_true)

# How far each sRGB color is from the true color, because colors outside the
# range of sRGB are clipped
srgb_error = colordiff.(srgb, XYZ_true; metric=DE_2000())

csv = joinpath(@__DIR__, "michel_levy_0-1600nm.csv")
open(csv, "w") do io
    println(io, "path_difference_nm,",
                "sorensen2013_R,sorensen2013_G,sorensen2013_B,",
                "srgb_R,srgb_G,srgb_B,srgb_error_dE2000,",
                "X,Y,Z,L,a,b")
    for i in eachindex(Γ)
        x, l = XYZ_true[i], Lab_true[i]
        @printf(io, "%d,%d,%d,%d,%d,%d,%d,%.2f,%.5f,%.5f,%.5f,%.3f,%.3f,%.3f\n",
                Γ[i], to255(sorensen[i])..., to255(srgb[i])..., srgb_error[i],
                x.x, x.y, x.z, l.l, l.a, l.b)
    end
end
println("Wrote ", csv)

# Picture of both sets of colors, to check the table by eye. Images are drawn
# with square pixels, so each strip spans 150 units in y to make it tall
strip(colors) = repeat(permutedims(colors), 2)
strip_plot(colors; kw...) = plot(Γ, [0, 150], strip(colors); yticks=false,
                                 xticks=0:100:1600, kw...)
p1 = strip_plot(sorensen, title="Sørensen (2013) settings")
p2 = strip_plot(srgb, title="Default settings (D65, white balanced, sRGB)",
                xlabel="Path difference Γ (nm)")
fig = plot(p1, p2, layout=(2, 1), size=(1200, 420), margin=5Plots.mm)
png = joinpath(@__DIR__, "michel_levy_0-1600nm.png")
savefig(fig, png)
println("Wrote ", png)
