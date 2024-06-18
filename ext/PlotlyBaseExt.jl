module PlotlyBaseExt
using PlotlyBase
using CountriesBorders: Multi, Domain, PolyArea, extract_plot_coords, SimpleLatLon

function PlotlyBase.scattergeo(p::Union{<:Multi{2, <:SimpleLatLon}, <:Domain{2, <:SimpleLatLon}, <:PolyArea{2, <:SimpleLatLon}}; kwargs...)
	lon, lat = extract_plot_coords(p)
	scattergeo(; lat, lon, mode="lines", kwargs...)
end

end