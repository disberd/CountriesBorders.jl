using CountriesBorders
using CountriesBorders: possible_selector_values, valid_column_names, mergeSkipDict, validate_skipDict, skipall, SkipDict, skipDict, GeoTablesConversion.geomcolumn
using Meshes
using CoordRefSystems
using Test
using Unitful

example1 = extract_countries(;continent = "europe", admin="-russia")
example2 = extract_countries(;admin="-russia", continent = "europe")
example3 = extract_countries(;subregion = "*europe; -eastern europe")
@testset "Test Docstring Examples" begin
    @test !isnothing(example1)
    @test !isnothing(example2)
    @test !isnothing(example3)
    @test length(example2) == length(example1) + 1
    @test !isnothing(extract_countries(;ConTinEnt = "Asia"))

    # We test the skip_areas example

    included_cities = cities = [
        SimpleLatLon(41.9, 12.49) # Rome
        SimpleLatLon(39.217, 9.113) # Cagliari
        SimpleLatLon(48.864, 2.349) # Paris
        SimpleLatLon(59.913, 10.738) # Oslo
    ] .|> Meshes.Point

    excluded_cities = cities = [
        LatLon(37.5, 15.09) # Catania
        LatLon(40.416, -3.703) # Madrid
        LatLon(5.212, -52.773) # Guiana Space Center
        LatLon(78.222, 15.652) # Svalbard Museum
    ]

    dmn_excluded = extract_countries("italy; spain; france; norway"; skip_areas = [
        ("Italy", 2)
        "Spain"
        SKIP_NONCONTINENTAL_EU
    ])
    @test all(in(dmn_excluded), included_cities)
    @test all(!in(dmn_excluded), excluded_cities)

    # Check wrapping
    @test SimpleLatLon(41.9, 12.49 + 360) in dmn_excluded

    dmn_full = extract_countries("italy; spain; france; norway")
    @test all(in(dmn_full), included_cities)
    @test all(in(dmn_full), excluded_cities)
end

# We test the array method
dm1 = extract_countries("italy; spain; france; norway")
dm2 = extract_countries(["italy","spain","france","norway"])
@test length(dm1) == length(dm2)

# We test that sending a regex throws
@test_throws "Vector{String}" extract_countries(; admin = r"france")

# we do coverage for possible_selector_values and valid_column_names
possible_selector_values()
valid_column_names()

# Test that extract_countries returns nothing if no matching country is found
@test extract_countries("IDFSDF") === nothing

# skip_polyarea coverage
sfa1 = SkipFromAdmin("France", :)
sfa2 = SkipFromAdmin("France", 1)
sd = mergeSkipDict([
    sfa1
    sfa2
])

@test sfa1 |> skipall # France should be skipall
@test !skipall(sfa2)
@test sd["France"] |> skipall # The merge should have kept the skipall

validate_skipDict(sd) # Check it doesn't error
@test_throws "more than one row" validate_skipDict(skipDict(("A", :)))
@test_throws "no match" validate_skipDict(skipDict(("Axiuoiasdf", :)))
@test_throws "greater than" validate_skipDict(skipDict(("Italy", 35)))

sfa3 = merge(sfa2, sfa1)
@test skipall(sfa3)
@test !skipall(sfa2) # merge shouldn't have changed sfa2
sfa4 = merge!(sfa2, sfa1)
@test skipall(sfa4)
@test skipall(sfa2) # merge! should have changed sfa2

sfa = SkipFromAdmin("France", 1)
sfb = SkipFromAdmin("France", 1:3)
@test sfb.idxs != sfa.idxs
merge!(sfa, SkipFromAdmin("France", 2), SkipFromAdmin("France", 3))
@test sfb.idxs == sfa.idxs

@testset "Conversions" begin
    ValidUnion = Union{SimpleLatLon, LatLon}
    function ≈(a::ValidUnion, b::ValidUnion)
        for name in (:lat, :lon)
            av = getproperty(a, name) |> ustrip
            bv = getproperty(b, name) |> ustrip
            Base.isapprox(av, bv) || false
        end
        return true
    end
    ≈(a,b) = Base.isapprox(a,b)
    sll_wgs = SimpleLatLon(10,20)
    ll_wgs = convert(LatLon{WGS84Latest}, sll_wgs)
    ll_itrf = convert(LatLon{ITRF{2008}}, sll_wgs)
    sll_itrf = convert(SimpleLatLon{ITRF{2008}}, ll_itrf)
    ll_itrf2 = convert(LatLon{ITRF{2008}}, LatLon(10f0,20f0))
    @test sll_itrf ≈ ll_itrf ≈ ll_itrf2
    @test sll_itrf ≈ convert(SimpleLatLon{ITRF{2008}}, sll_wgs)
    rad = 1u"rad"
    @test SimpleLatLon(90,90) ≈ SimpleLatLon(π/2 * rad, π/2 * rad)

    # Test constructor errors and longitude wrapping
    @test_throws "between -90° and 90°" SimpleLatLon(180, 2)
    @test SimpleLatLon(0, 41 + 360).lon |> ustrip ≈ 41
end

@test_throws "geometry column not found" geomcolumn([:asd, :lol])