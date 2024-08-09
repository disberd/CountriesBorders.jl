const LATLON{T} = LatLon{WGS84Latest,Deg{T}}

function cartesian_geometry(poly::PolyArea{🌐,<:LATLON})
    map(rings(poly)) do r
        map(Meshes.flat, vertices(r)) |> Ring
    end |> splat(PolyArea)
end
cartesian_geometry(multi::Multi{🌐,<:LATLON}) =
    map(cartesian_geometry, parent(multi)) |> Multi


struct CountryBorder{T,LL,CA} <: Geometry{🌐,LATLON{T}}
    "Name of the Country, i.e. the ADMIN entry in the GeoTable"
    admin::String
    "The index of the country in the original GeoTable"
    table_idx::Int
    "The borders in LatLon CRS"
    latlon::LL
    "The borders in Cartesian2D CRS"
    cart::CA
    function CountryBorder(admin::String, geom::G) where {T,G<:Geometry{🌐,LATLON{T}}}
        cart = cartesian_geometry(geom)
        CA = typeof(cart)
        new{T,G,CA}(admin, geom, cart)
    end
end

const DOMAIN{T} = GeometrySet{🌐, LATLON{T}, CountryBorder{T}}
const SUBDOMAIN{T} = SubDomain{🌐, LATLON{T}, <:DOMAIN{T}}

floattype(::CountryBorder{T}) where {T} = T
floattype(::DOMAIN{T}) where {T} = T

# Meshes/Base methods overloads #
Meshes.paramdim(cb::CountryBorder) = paramdim(cb.latlon)

function Meshes.prettyname(d::DOMAIN) 
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