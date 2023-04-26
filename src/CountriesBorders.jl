module CountriesBorders

include("../notebooks/main_implementation.jl")

function __init__()
	shapefile = joinpath(dirname(Base.current_project(@__DIR__)), "assets", "ne_110m_admin_0_countries_lakes.shp")
    GEOTABLE[] = GeoTables.load(shapefile)
end

end # module CountriesBorders
