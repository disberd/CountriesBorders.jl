module GeoTablesConversion
    using Meshes
    using Meshes: Geometry, Manifold, CRS, 🌐, Multi, 𝔼, Point, prettyname, printinds, MultiPolygon, printelms
    using CircularArrays: CircularArray
    using GeoTables
    using Tables
    import GeoInterface as GI
    using CoordRefSystems
    using CoordRefSystems: Deg, Met
    using Unitful

    export CountryBorder, borders, DOMAIN, remove_polyareas!, npolyareas

    include("main_type.jl")
    include("conversion_utils.jl")
end

using .GeoTablesConversion
using .GeoTablesConversion: VALID_POINT, LATLON, CART, VALID_RING
