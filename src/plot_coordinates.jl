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
function extract_plot_coords(pa::PolyArea{2, <:SimpleLatLon})
    length(rings(pa)) === 1 && return extract_plot_coords(rings(pa) |> first)
    lat = Float32[]
    lon = Float32[]
    for ring ∈ rings(pa)
        c = extract_plot_coords(ring)
        append!(lat, c.lat)
        append!(lon, c.lon)
        if ring !== last(rings(pa))
            push!(lat, NaN32)
            push!(lon, NaN32)
        end
    end
	(;lon,lat)
end

function extract_plot_coords(md::Union{Multi{2, <:SimpleLatLon}, Domain{2, <:SimpleLatLon}})
    geoms = parent(md)
	lon = Float32[]
	lat = Float32[]
	for geom ∈ geoms
		c = extract_plot_coords(geom)
        append!(lat, c.lat)
        append!(lon, c.lon)
        if geom !== last(geoms)
            push!(lat, NaN32)
            push!(lon, NaN32)
        end
	end
	(;lon,lat)
end