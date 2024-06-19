#=
The contents o this file have been mostly taken and adapted from the
[CoordRefSystems.jl](https://github.com/JuliaEarth/CoordRefSystems.jl) package
which is licensed under MIT license.
The corresponding MIT License is copied below:

MIT License

Copyright (c) 2024 Elias Carvalho <eliascarvdev@gmail.com> and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=#
using CoordRefSystems: Deg, Rad, Geographic, Datum, addunit, WGS84Latest


"""
    SimpleLatLon(lat, lon)
    SimpleLatLon{Datum}(lat, lon)
Simple structure mirroring `LatLon` from CoordRefSystems. It defaults to Float32 precision on the fields (expressed in ° from Unitful) and is used to simplify the check for inclusion in a 2d PolyArea on the world.

Contrary to `LatLon`, the constructor for LatLon also enforces the latitude to be between -90° and 90°, and wraps the longitude so it's value is ensured to be between -180° and 180°.

The domain returned from [`extract_countries`](@ref) is composed of `Meshes.Point` points with `SimpleLatLon` coordinates.
"""
struct SimpleLatLon{Datum,D<:Deg} <: Geographic{Datum}
    lat::D
    lon::D
    function SimpleLatLon{Datum, D}(lat::Deg, lon::Deg) where {Datum, D}
        @assert abs(lat) <= π/2 "You must provide a latitude between -90° and 90°"
        # We wrap directly the lon to make sure it's 
        lon = rem(lon, 360u"°", RoundNearest)
        new{Datum, D}(lat, lon)
    end
end

const Deg32 = typeof(1f0u"°")

CoordRefSystems.ndims(::Type{<:SimpleLatLon}) = 2

SimpleLatLon{Datum}(lat::Deg, lon::Deg) where {Datum} = SimpleLatLon{Datum, Deg32}(lat, lon)
SimpleLatLon{Datum}(lat::Rad, lon::Rad) where {Datum} = SimpleLatLon{Datum}(rad2deg(lat), rad2deg(lon))
SimpleLatLon{Datum}(lat::Number, lon::Number) where {Datum} =
    SimpleLatLon{Datum}(addunit(lat, u"°"), addunit(lon, u"°"))

# Catchall
SimpleLatLon(args...) = SimpleLatLon{WGS84Latest}(args...)

Base.convert(::Type{SimpleLatLon{Datum,D}}, coords::SimpleLatLon{Datum}) where {Datum,D} =
    SimpleLatLon{Datum,D}(coords.lat, coords.lon)

function Base.convert(::Type{Cartesian}, sll::SimpleLatLon{Datum}) where Datum 
    fake_lat = ustrip(sll.lat)
    fake_lon = ustrip(sll.lon)
    return Cartesian{Datum}(fake_lon, fake_lat)
end


# Convert from normal LatLon
function Base.convert(::Type{LatLon{Datumₜ, D}}, sll::SimpleLatLon{Datumₛ}) where {Datumₜ, Datumₛ, D} 
    llₛ = LatLon{Datumₛ, D}(sll.lat, sll.lon)
    out = Datumₛ === Datumₜ ? llₛ : convert(LatLon{Datumₜ}, llₛ)
    return out
end
function Base.convert(::Type{SimpleLatLon{Datumₜ, D}}, llₛ::LatLon{Datumₛ}) where {Datumₜ, Datumₛ, D} 
    llₜ = Datumₛ === Datumₜ ? llₛ : convert(LatLon{Datumₜ}, llₛ)
    return SimpleLatLon{Datumₜ, D}(llₜ.lat, llₜ.lon)
end

Base.convert(::Type{SimpleLatLon{Datumₜ}}, llₛ::LatLon{Datumₛ, D}) where {Datumₜ, Datumₛ, D} = convert(SimpleLatLon{Datumₜ, D}, llₛ)
Base.convert(::Type{LatLon{Datumₜ}}, sll::SimpleLatLon{Datumₛ, D}) where {Datumₜ, Datumₛ, D} = convert(LatLon{Datumₜ, D}, sll)


Base.convert(::Type{SimpleLatLon{Datumₜ}}, sll::SimpleLatLon) where {Datumₜ} = convert(SimpleLatLon{Datumₜ}, convert(LatLon{Datumₜ}, sll))

SimpleLatLon{Datum, D}(ll::Union{LatLon, SimpleLatLon}) where {Datum, D} = convert(SimpleLatLon{Datum, D}, ll)

# Overload the meshes method for fixing `in`
function Meshes.∠(A::S, B::P, C::S) where {Datum, S<:Point{2, <:SimpleLatLon{Datum}}, P<:Point{2, <:Cartesian{Datum}}} 
    A = convert(Cartesian, coords(A)) |> Point
    C = convert(Cartesian, coords(C)) |> Point
    Meshes.∠(A - B, C - B)
end

const SimpleRegion{Datum, D} = Union{PolyArea{2, SimpleLatLon{Datum, D}}, Multi{2, SimpleLatLon{Datum, D}}, Domain{2, SimpleLatLon{Datum, D}}}

# Add specific catchall methods for `in`
function Base.in(ll::Union{SimpleLatLon, LatLon}, region::SimpleRegion{Datum, D}) where {Datum, D} 
    sll = SimpleLatLon{Datum, D}(ll)
    return Point(sll) in region
end

# Add a method for `in` for NamedTuple inputs
function Base.in(nt::Union{NamedTuple{(:lat, :lon)}, NamedTuple{(:lon, :lat)}}, region::SimpleRegion{Datum, D}) where {Datum, D}
    (;lat, lon) = nt
    sll = SimpleLatLon{Datum}(lat, lon)
    sll_D = convert(SimpleLatLon{Datum, D}, sll)
    return Point(sll_D) in region
end