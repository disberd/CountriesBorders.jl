const GEOTABLE_RESOLUTION = Ref{Tuple{GeoTables.GeoTable, Int}}()

function set_geotable!(geotable::GeoTables.GeoTable, resolution::Int)
    GEOTABLE_RESOLUTION[] = (geotable, resolution)
end
function get_default_geotable_resolution()
    if isassigned(GEOTABLE_RESOLUTION)
        table, resolution = GEOTABLE_RESOLUTION[]
        return table, resolution
    else
        resolution = 110
        table = get_geotable(; resolution)
        set_geotable!(table, resolution)
        return table, resolution
    end
end
function get_geotable(; resolution = nothing, kwargs...)
    @assert isnothing(resolution) || resolution in (10, 50, 110) "The resolution can only be either `10`, `50` or `110`"
    isnothing(resolution) && return get_default_geotable_resolution() |> first
    resolution = Int(resolution)
    admin_geojson = naturalearth("admin_0_countries_lakes", resolution)
    table = GeoTablesConversion.asgeotable(admin_geojson, true)
    return table
end