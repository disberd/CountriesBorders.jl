# Extracting lat/lon coordaintes of the borders
function extract_plot_coords(ring::Ring{2, <:SimpleLatLon})
    nelem = nvertices(ring) + 1
    f = Float32 ∘ ustrip
    lat = Vector{Float32}(undef, nelem)
    lon = Vector{Float32}(undef, nelem)
    for (i, p) in enumerate(vertices(ring))
        c = coords(p)
        lat[i] = c.lat |> f
        lon[i] = c.lon |> f
    end
    lat[end] = lat[1]
    lon[end] = lon[1]
	return (;lon, lat)
end

geom_iterable(pa::PolyArea) = rings(pa)
geom_iterable(m::Multi) = parent(m)
geom_iterable(d::Domain) = d

function extract_plot_coords(inp::Union{Multi{2, <:SimpleLatLon}, Domain{2, <:SimpleLatLon}, PolyArea{2, <:SimpleLatLon}})
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
	(;lon,lat)
end