module PlotlyBaseExt
using PlotlyBase
using CountriesBorders: Multi, Domain, PolyArea, extract_plot_coords, LatLon, SimpleRegion

function PlotlyBase.scattergeo(p::SimpleRegion; kwargs...)
	(;lon, lat) = extract_plot_coords(p)
	scattergeo(; lat, lon, mode="lines", kwargs...)
end

# This is type piracy so it should be removed probably
function PlotlyBase.scattergeo(ps::Vector{<:LatLon}; kwargs...)
	(;lon, lat) = extract_plot_coords(ps)
	scattergeo(; lat, lon, kwargs...)
end

end