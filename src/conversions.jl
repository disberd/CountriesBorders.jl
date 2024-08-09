module GeoTablesConversion
    using Meshes
    using Meshes: Geometry, Manifold, CRS, 🌐, Multi, 𝔼, Point, prettyname, printinds, MultiPolygon
    using CircularArrays: CircularArray
    using GeoTables
    using Tables
    import GeoInterface as GI
    using CoordRefSystems
    using CoordRefSystems: Deg, Met
    using Unitful

    export CountryBorder, borders, DOMAIN

    include("main_type.jl")
    include("conversion_utils.jl")
end

using .GeoTablesConversion
