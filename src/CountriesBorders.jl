module CountriesBorders

using GeoTables
using Meshes
using GeoInterface
using Tables
using GeoJSON
using Artifacts
using Unitful: Unitful, ustrip
using PrecompileTools

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

const GEOTABLE = Ref{GeoTables.GeoTable}()

# This we default to Float64 for compatibility 
get_default_geojson(; kwargs...) = GeoJSON.read(joinpath(artifact"ne_110m_admin_geojson", "ne_110m_admin_0_countries_lakes.geojson"); kwargs...)
function get_default_geotable(; use_stored = true, kwargs...)
    if isassigned(GEOTABLE) && use_stored
        GEOTABLE[]
    else
        admin_geojson = get_default_geojson(;kwargs...)
        table = GeoTablesConversion.asgeotable(admin_geojson, true)
        use_stored && (GEOTABLE[] = table)
        table
    end
end


include("skip_polyarea.jl")
include("implementation.jl")
include("plot_coordinates.jl")

@compile_workload begin
    admin_geojson = get_default_geojson(;)
    table = GeoTablesConversion.asgeotable(admin_geojson, true)
    dmn = extract_countries("italy; spain")
    rome = SimpleLatLon(41.9, 12.49)
    rome in dmn # Returns true
end

end # module CountriesBorders
