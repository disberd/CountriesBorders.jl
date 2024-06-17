module CountriesBorders

using GeoTables
using Meshes
using GeoInterface
using Tables
using GeoJSON
using Artifacts

export extract_countries, SKIP_NONCONTINENTAL_EU, SkipFromAdmin

module GeoTablesConversion
    using Meshes
    using GeoTables
    using Tables
    import GeoInterface as GI
    using CoordRefSystems
    include("conversion_utils.jl")
end

const GEOTABLE = Ref{GeoTables.GeoTable}()

# This we default to Float64 for compatibility 
get_default_geojson(;numbertype = Float64) = GeoJSON.read(joinpath(artifact"ne_110m_admin_geojson", "ne_110m_admin_0_countries_lakes.geojson"); numbertype)
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

end # module CountriesBorders
