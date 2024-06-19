using SafeTestsets

@safetestset "Aqua" begin
    using Aqua
    using CountriesBorders
    Aqua.test_all(CountriesBorders; ambiguities = false)
    Aqua.test_ambiguities(CountriesBorders)
end

@safetestset "Basic" begin include("basics.jl") end
@safetestset "Extensions" begin include("extensions.jl") end