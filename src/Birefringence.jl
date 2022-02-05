module Birefringence

export birefringence_array
export Standard, Protanopia, Deuteranopia, Tritanopia
export Protanomaly, Deuteranomaly, Tritanomaly

import Images.RGB
import Images.protanopic, Images.deuteranopic, Images.tritanopic

include("utils.jl")
include("physics.jl")
include("color_matching_functions.jl")
include("tristimulus.jl")
include("RGB.jl")
include("color_deficiencies.jl")
include("wrappers.jl")

end # module
