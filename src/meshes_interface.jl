# Forwarding relevant meshes functions for the CountryBorder type
const VALID_CRS = Type{<:Union{LatLon, Cartesian}}

# LatLon fallbacks
Meshes.measure(cb::CountryBorder) = measure(borders(LatLon, cb))
Meshes.nvertices(cb::CountryBorder) = nvertices(borders(LatLon, cb))

# Cartesian fallbacks
Meshes.boundingbox(cb::CountryBorder) = boundingbox(borders(Cartesian, cb))

Meshes.centroid(crs::VALID_CRS, cb::CountryBorder) = centroid(borders(crs, cb))
Meshes.centroid(cb::CountryBorder) = centroid(Cartesian, cb)

Meshes.discretize(crs::VALID_CRS, cb::CountryBorder) = discretize(borders(crs, cb))
Meshes.discretize(cb::CountryBorder) = discretize(Cartesian, cb)

Meshes.rings(crs::VALID_CRS, cb::CountryBorder) = rings(borders(crs, cb))
Meshes.rings(cb::CountryBorder) = rings(Cartesian, cb)

Meshes.vertices(crs::VALID_CRS, cb::CountryBorder) = vertices(borders(crs, cb))
Meshes.vertices(cb::CountryBorder) = vertices(Cartesian, cb)

Meshes.simplexify(crs::VALID_CRS, cb::CountryBorder) = simplexify(borders(crs, cb))
Meshes.simplexify(cb::CountryBorder) = simplexify(Cartesian, cb)

Meshes.pointify(crs::VALID_CRS, cb::CountryBorder) = pointify(borders(crs, cb))
Meshes.pointify(cb::CountryBorder) = pointify(Cartesian, cb)

# Base methods
Base.in(p::Point{𝔼{2}, <:Cartesian2D{WGS84Latest}}, cb::CountryBorder) = in(p, borders(Cartesian, cb))
Base.in(p::Point{🌐, <:LatLon{WGS84Latest}}, cb::CountryBorder) = in(Meshes.flat(p), cb)
Base.in(p::LatLon, cb::CountryBorder) = in(Point(LatLon{WGS84Latest, Deg{Float32}}(p.lat, p.lon)), cb)
Base.in(p::LatLon, dmn::DOMAIN) = Point(p) in dmn