const LATLON{T} = LatLon{WGS84Latest,Deg{T}}
const CART{T} = Cartesian2D{WGS84Latest,Met{T}}

const POINT_LATLON{T} = Point{🌐, LATLON{T}}
const POINT_CART{T} = Point{𝔼{2}, CART{T}}

const RING_LATLON{T} = Ring{🌐, LATLON{T}, CircularArray{POINT_LATLON{T}, 1, Vector{POINT_LATLON{T}}}}
const RING_CART{T} = Ring{𝔼{2}, CART{T}, CircularArray{POINT_CART{T}, 1, Vector{POINT_CART{T}}}}

const POLY_LATLON{T} = PolyArea{🌐, LATLON{T}, RING_LATLON{T}, Vector{RING_LATLON{T}}}
const POLY_CART{T} = PolyArea{𝔼{2}, CART{T}, RING_CART{T}, Vector{RING_CART{T}}}

const MULTI_LATLON{T} = Multi{🌐, LATLON{T}, POLY_LATLON{T}}
const MULTI_CART{T} = Multi{𝔼{2}, CART{T}, POLY_CART{T}}

struct CountryBorder{T} <: Geometry{🌐,LATLON{T}}
    "Name of the Country, i.e. the ADMIN entry in the GeoTable"
    admin::String
    "The index of the country in the original GeoTable"
    table_idx::Int
    "The borders in LatLon CRS"
    latlon::MULTI_LATLON{T}
    "The borders in Cartesian2D CRS"
    cart::MULTI_CART{T}
    function CountryBorder(admin::String, geom::G, idx::Int) where {T,G<:Union{MULTI_LATLON{T}, POLY_LATLON{T}}}
        latlon = geom isa MULTI_LATLON ? geom : Multi([geom])
        cart = cartesian_geometry(latlon)
        new{T}(admin, idx, latlon, cart)
    end
end

const GSET{T} = GeometrySet{🌐, LATLON{T}, CountryBorder{T}}
const SUBDOMAIN{T} = SubDomain{🌐, LATLON{T}, <:GSET{T}}
const DOMAIN{T} = Union{GSET{T}, SUBDOMAIN{T}}

function cartesian_geometry(poly::PolyArea{🌐,<:LATLON})
    map(rings(poly)) do r
        map(Meshes.flat, vertices(r)) |> Ring
    end |> splat(PolyArea)
end
cartesian_geometry(multi::Multi{🌐,<:LATLON}) =
    map(cartesian_geometry, parent(multi)) |> Multi


floattype(::CountryBorder{T}) where {T} = T
floattype(::DOMAIN{T}) where {T} = T

borders(cb::CountryBorder, ::Type{LatLon}) = cb.latlon
borders(cb::CountryBorder, ::Type{Cartesian}) = cb.cart
borders(cb::CountryBorder) = borders(cb, LatLon)

# Meshes/Base methods overloads #
Meshes.paramdim(cb::CountryBorder) = paramdim(cb.latlon)

function Meshes.prettyname(d::GSET) 
    T = floattype(d)
    "GeometrySet{CountryBorder{$T}}"
end

## IO ##
function Base.summary(io::IO, cb::CountryBorder) 
    print(io, cb.admin)
    print(io, " Borders")
end

function Base.show(io::IO, cb::CountryBorder)
    print(io, cb.admin)
end

function Base.show(io::IO, mime::MIME"text/plain", cb::CountryBorder)
    print(io, cb.admin)
    print(io, ", $(floattype(cb)), ")
    show(io, mime, cb.latlon)
end