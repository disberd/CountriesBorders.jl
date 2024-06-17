module CountriesBorders

using GeoTables
using Meshes
using GeoInterface
using Tables
using GeoJSON
using Artifacts

export extract_countries, SKIP_NONCONTINENTAL_EU, SkipFromAdmin

const GEOTABLE = Ref{GeoTables.GeoTable}()

module GeoTablesConversion
    using Meshes
    using GeoTables
    using Tables
    import GeoInterface as GI
    include("conversion_utils.jl")
end

include("skip_polyarea.jl")
include("implementation.jl")

function __init__()
    admin_geojson = GeoJSON.read(joinpath(artifact"ne_110m_admin_geojson", "ne_110m_admin_0_countries_lakes.geojson"))
    GEOTABLE[] = GeoTablesConversion.asgeotable(admin_geojson, true)
end

end # module CountriesBorders
