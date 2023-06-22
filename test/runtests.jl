using Test
using CountriesBorders


example1 = extract_countries(;continent = "europe", admin="-russia")
example2 = extract_countries(;admin="-russia", continent = "europe")
example3 = extract_countries(;subregion = "*europe; -eastern europe")
@testset "Test Docstring Examples" begin
    @test !isnothing(example1)
    @test !isnothing(example2)
    @test !isnothing(example3)
    @test length(example2) == length(example1) + 1
    @test !isnothing(extract_countries(;ConTinEnt = "Asia"))
end