module PlotlyBaseExt
using PlotlyBase
using CountriesBorders: Multi, Domain, PolyArea, extract_plot_coords, SimpleLatLon, SimpleRegion

function PlotlyBase.scattergeo(p::SimpleRegion; kwargs...)
	lon, lat = extract_plot_coords(p)
	scattergeo(; lat, lon, mode="lines", kwargs...)
end

function PlotlyBase.scattergeo(ps::Vector{<:SimpleLatLon}; kwargs...)
	lon, lat = extract_plot_coords(p)
	scattergeo(; lat, lon, kwargs...)
end

end