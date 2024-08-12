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
    "Indices of skipped PolyAreas in the original MultiPolygon of the country"
    valid_polyareas::BitVector
    "The resolution of the underlying border sampling from the NaturalEarth dataset"
    resolution::Int
    "The borders in LatLon CRS"
    latlon::MULTI_LATLON{T}
    "The borders in Cartesian2D CRS"
    cart::MULTI_CART{T}
    function CountryBorder(admin::String, latlon::MULTI_LATLON{T}, valid_polyareas::BitVector; resolution::Int, table_idx::Int) where {T}
        ngeoms = length(latlon.geoms)
        sum(valid_polyareas) === ngeoms || error("The number of set bits in the `valid_polyareas` vector must be equivalent to the number of PolyAreas in the `geom` input argument")
        cart = cartesian_geometry(latlon)
        new{T}(admin, table_idx, valid_polyareas, resolution, latlon, cart)
    end
end
function CountryBorder(admin::AbstractString, geom::POLY_LATLON, valid_polyareas = BitVector((true,)); kwargs...)
    multi = Multi([geom])
    CountryBorder(String(admin), multi, BitVector(valid_polyareas); kwargs...)
end
function CountryBorder(admin::AbstractString, multi::MULTI_LATLON, valid_polyareas = BitVector(ntuple(i -> true, length(multi.geoms))); kwargs...)
    CountryBorder(String(admin), multi, BitVector(valid_polyareas); kwargs...)
end

function remove_polyareas!(cb::CountryBorder, idx::Int)
    (; valid_polyareas, latlon, cart, admin, resolution) = cb
    ngeoms = length(valid_polyareas)
    @assert idx ≤ ngeoms "You are trying to remove the $idx-th PolyArea from $(admin) but that country is only composed of $ngeoms PolyAreas for the considered resolution ($(resolution)m)."
    if !valid_polyareas[idx] 
        @info "The $idx-th PolyArea in $(admin) has already been removed"
        return cb
    end
    @assert sum(valid_polyareas) > 1 "You can't remove all PolyAreas from a `CountryBorder` object"
    # We find the idx while accounting for already removed polyareas
    current_idx = @views sum(valid_polyareas[1:idx])
    for g in (latlon, cart)
        deleteat!(g.geoms, current_idx)
    end
    valid_polyareas[idx] = false
    return cb
end
function remove_polyareas!(cb::CountryBorder, idxs)
    for idx in idxs
        remove_polyareas!(cb, idx)
    end
    return cb
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

borders(::Type{LatLon}, cb::CountryBorder) = cb.latlon
borders(::Type{Cartesian}, cb::CountryBorder) = cb.cart
borders(cb::CountryBorder) = borders(LatLon, cb)

resolution(cb::CountryBorder) = cb.resolution
resolution(d::GSET) = resolution(element(d, 1))

# Meshes/Base methods overloads #
Meshes.paramdim(cb::CountryBorder) = paramdim(cb.latlon)

function Meshes.prettyname(d::GSET) 
    T = floattype(d)
    res = resolution(d)
    "GeometrySet{CountryBorder{$T}}, resolution = $(res)m"
end

## IO ##
function Base.summary(io::IO, cb::CountryBorder) 
    print(io, cb.admin)
    print(io, " Borders")
end

function Base.show(io::IO, cb::CountryBorder)
    print(io, cb.admin)
    nskipped = sum(!, cb.valid_polyareas)
    if nskipped > 0
        print(io, " ($nskipped skipped)")
    end
end

function Base.show(io::IO, mime::MIME"text/plain", cb::CountryBorder)
    (; admin, valid_polyareas, latlon) = cb
    print(io, admin)
    print(io, ", $(floattype(cb)), $(resolution(cb))m")
    nskipped = sum(!, valid_polyareas)
    if nskipped > 0
        print(io, ", $nskipped skipped")
    end
    println(io)
    v = Any["Skipped PolyArea" for _ in 1:length(valid_polyareas)]
    v[valid_polyareas] = latlon.geoms
    printelms(io, v)
end