abstract type Vision end

struct Standard <: Vision end

struct Protanopia <: Vision end
struct Deuteranopia <: Vision end
struct Tritanopia <: Vision end

struct Protanomaly <: Vision
    p::Float64
    function Protanomaly(p=0.5)
        @assert p <= 1
        @assert 0 <= p
        return new(p)
    end
end
struct Deuteranomaly <: Vision
    p::Float64
    function Deuteranomaly(p=0.5)
        @assert p <= 1
        @assert 0 <= p
        return new(p)
    end
end
struct Tritanomaly <: Vision
    p::Float64
    function Tritanomaly(p=0.5)
        @assert p <= 1
        @assert 0 <= p
        return new(p)
    end
end

visualise(rgb, vision::Standard) = rgb
visualise(rgb, vision::Protanopia) = protanopic.(rgb)
visualise(rgb, vision::Deuteranopia) = deuteranopic.(rgb)
visualise(rgb, vision::Tritanopia) = tritanopic.(rgb)
visualise(rgb, vision::Protanomaly) = protanopic.(rgb, vision.p)
visualise(rgb, vision::Deuteranomaly) = deuteranopic.(rgb, vision.p)
visualise(rgb, vision::Tritanomaly) = tritanopic.(rgb, vision.p)
