module Birefringence

export birefringence_array
export AdobeRGB, sRGB
export D65, IlluminantE, IlluminantA, Blackbody
export sorensen2013
export Standard, Protanopia, Deuteranopia, Tritanopia
export Protanomaly, Deuteranomaly, Tritanomaly

import Images.RGB
import Images.protanopic, Images.deuteranopic, Images.tritanopic
using LinearAlgebra: Diagonal, inv

include("utils.jl")
include("physics.jl")
include("color_matching_functions.jl")
include("illuminants.jl")
include("tristimulus.jl")
include("adaptation.jl")
include("RGB.jl")
include("color_deficiencies.jl")
include("wrappers.jl")
include("presets.jl")

end # module
