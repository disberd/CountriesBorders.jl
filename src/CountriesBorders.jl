module CountriesBorders

using GeoTables
using Meshes
using Meshes: 🌐
using GeoInterface
using Tables
using GeoJSON
using Artifacts
using Unitful: Unitful, ustrip
using PrecompileTools
using NaturalEarth: NaturalEarth, naturalearth
using CoordRefSystems

export extract_countries, SKIP_NONCONTINENTAL_EU, SkipFromAdmin, SimpleLatLon, LatLon, Point
export CountryBorder

function SimpleLatLon(args...)
    #! format: off
@warn "The use of SimpleLatLon is deprecated since v0.4.0 of CountriesBorders.
The package internally now relies on LatLon from CoordRefSystems directly, so you should use that instead.
"
    #! format: on
    return LatLon(args...)
end
const SimpleRegion{Datum, D} = Union{PolyArea{🌐, LatLon{Datum, D}}, Multi{🌐, LatLon{Datum, D}}, Domain{🌐, LatLon{Datum, D}}}

include("conversions.jl")
include("geotable.jl")
include("skip_polyarea.jl")
include("implementation.jl")
include("plot_coordinates.jl")

@compile_workload begin
    table = get_geotable()
    dmn = extract_countries("italy; spain")
    rome = SimpleLatLon(41.9, 12.49)
    rome in dmn # Returns true
end

end # module CountriesBorders
