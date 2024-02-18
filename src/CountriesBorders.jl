module CountriesBorders

using GeoTables
using Meshes
using GeoInterface
using Tables

export extract_countries, SKIP_NONCONTINENTAL_EU, SkipFromAdmin

const GEOTABLE = Ref{GeoTables.GeoTable}()

include("skip_polyarea.jl")
include("implementation.jl")

function __init__()
	shapefile = joinpath(dirname(Base.current_project(@__DIR__)), "assets", "ne_110m_admin_0_countries_lakes.shp")
    GEOTABLE[] = GeoTables.load(shapefile)
end

end # module CountriesBorders
