module GeoTablesConversion
    using Meshes
    using Meshes: Geometry, Manifold, CRS, 🌐, Multi, 𝔼, Point, prettyname, printinds
    using GeoTables
    using Tables
    import GeoInterface as GI
    using CoordRefSystems
    using CoordRefSystems: Deg
    using Unitful

    export CountryBorder

    include("main_type.jl")
    include("conversion_utils.jl")
end

import .GeoTablesConversion: CountryBorder
