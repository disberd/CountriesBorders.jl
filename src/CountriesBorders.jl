module CountriesBorders

using GeoTables
using Meshes
using GeoInterface
using Tables
using GeoJSON
using Artifacts
using Unitful: Unitful, ustrip
using PrecompileTools
using NaturalEarth: NaturalEarth, naturalearth

export extract_countries, SKIP_NONCONTINENTAL_EU, SkipFromAdmin, SimpleLatLon

module GeoTablesConversion
    using Meshes
    using GeoTables
    using Tables
    import GeoInterface as GI
    using CoordRefSystems
    using Unitful

    export SimpleLatLon, SimpleRegion

    include("types.jl")
    include("conversion_utils.jl")
end
using .GeoTablesConversion


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
