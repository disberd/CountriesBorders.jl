# Extracting lat/lon coordaintes of the borders
function extract_plot_coords(ll::LATLON)
    (;lat, lon) = ll
    out = map(Float32 ∘ ustrip, (;lat, lon))
end
function extract_plot_coords(c::CART)
    lat = c.y
    lon = c.x
    out = map(Float32 ∘ ustrip, (;lat, lon))
end
extract_plot_coords(p::VALID_POINT) = extract_plot_coords(coords(p))
function extract_plot_coords(v::Vector)
    nelem = length(v)
    lat = Vector{Float32}(undef, nelem)
    lon = Vector{Float32}(undef, nelem)
    for i in eachindex(v, lat, lon)
        c = extract_plot_coords(v[i])
        lat[i] = c.lat
        lon[i] = c.lon
    end
    return (;lat, lon)
end

function extract_plot_coords(ring::VALID_RING)
    nelem = nvertices(ring)
    lat = Vector{Float32}(undef, nelem)
    lon = Vector{Float32}(undef, nelem)
    v = vertices(ring)
    for i in eachindex(v, lat, lon)
        c = extract_plot_coords(v[i])
        lat[i] = c.lat
        lon[i] = c.lon
    end
    # We add the first point to the end of the array to close the ring
    push!(lat, first(lat))
    push!(lon, first(lon))
    return (;lat, lon)
end

geom_iterable(pa::Union{Multi, PolyArea}) = rings(pa)
geom_iterable(cb::CountryBorder) = rings(borders(cb))
geom_iterable(d::Domain) = d

"""
    extract_plot_coords(inp)
Extract the lat and lon coordinates (in degrees) from the geometry/region `inp`
and return them in a `@NamedTuple{lat::Vector{Float32}, lon::Vector{Float32}`.

When `inp` is composed of multiple rings/polygons, the returned vectors `lat`
and `lon` contain the concateneated lat/lon values of each ring separated by
`NaN32` values. This is done to allow plotting multiple separated borders in a
single trace.
"""
function extract_plot_coords(inp::Union{Multi, PolyArea, RegionBorders})
    iterable = geom_iterable(inp)
    length(iterable) == 1 && return extract_plot_coords(first(iterable))
	lon = Float32[]
	lat = Float32[]
	for geom ∈ iterable
		c = extract_plot_coords(geom)
        append!(lat, c.lat)
        append!(lon, c.lon)
        if geom !== last(iterable)
            push!(lat, NaN32)
            push!(lon, NaN32)
        end
	end
	(;lat, lon)
end