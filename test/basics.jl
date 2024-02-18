using CountriesBorders
using Meshes

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
        (12.49, 41.9) # Rome
        (9.113, 39.217) # Cagliari
        (2.349, 48.864) # Paris
        (10.738, 59.913) # Oslo
    ] .|> Meshes.Point

    excluded_cities = cities = [
        (15.09, 37.5) # Catania
        (-3.703, 40.416) # Madrid
        (-52.773, 5.212) # Guiana Space Center
        (15.652, 78.222) # Svalbard Museum
    ] .|> Meshes.Point

    dmn_excluded = extract_countries("italy; spain; france; norway"; skip_areas = [
        ("Italy", 2)
        "Spain"
        SKIP_NONCONTINENTAL_EU
    ])
    @test all(in(dmn_excluded), included_cities)
    @test all(!in(dmn_excluded), excluded_cities)

    dmn_full = extract_countries("italy; spain; france; norway")
    @test all(in(dmn_full), included_cities)
    @test all(in(dmn_full), excluded_cities)
end