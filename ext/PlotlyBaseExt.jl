module PlotlyBaseExt
using PlotlyBase
using CountriesBorders: Multi, Domain, PolyArea, extract_plot_coords, LatLon, 🌐, Point, RegionBorders

function PlotlyBase.scattergeo(p::RegionBorders; kwargs...)
	(;lon, lat) = extract_plot_coords(p)
	scattergeo(; lat, lon, mode="lines", kwargs...)
end

# This is type piracy so it should be removed probably
function PlotlyBase.scattergeo(ps::Vector{<:Union{LatLon, Point{🌐, <:LatLon}}}; kwargs...)
	(;lon, lat) = extract_plot_coords(ps)
	scattergeo(; lat, lon, kwargs...)
end

end