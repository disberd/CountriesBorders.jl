# Extracting lat/lon coordaintes of the borders
function extract_plot_coords(sll::SimpleLatLon)
    (;lat, lon) = sll
    out = map(Float32 ∘ ustrip, (;lat, lon))
end
function extract_plot_coords(v::Vector{<:SimpleLatLon})
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

function extract_plot_coords(ring::Ring{2, <:SimpleLatLon})
    nelem = nvertices(ring)
    lat = Vector{Float32}(undef, nelem)
    lon = Vector{Float32}(undef, nelem)
    v = vertices(ring)
    for i in eachindex(v, lat, lon)
        c = coords(v[i]) |> extract_plot_coords
        lat[i] = c.lat
        lon[i] = c.lon
    end
    # We add the first point to the end of the array to close the ring
    push!(lat, first(lat))
    push!(lon, first(lon))
    return (;lat, lon)
end

geom_iterable(pa::Union{Multi, PolyArea}) = rings(pa)
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
	(;lat, lon)
end