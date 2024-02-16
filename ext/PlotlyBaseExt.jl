module PlotlyBaseExt
using PlotlyBase
using CountriesBorders: Multi, Domain, Polygon, extract_plot_coords

function PlotlyBase.scattergeo(p::Union{Multi, Domain, Polygon}; kwargs...)
	lon, lat = extract_plot_coords(p)
	scattergeo(; lat, lon, mode="lines", kwargs...)
end

end