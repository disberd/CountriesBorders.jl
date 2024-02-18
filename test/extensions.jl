using CountriesBorders
using PlotlyBase

# We just call scattergeo to try that it doesn't error
dmn = extract_countries("Italy")

dmn |> scattergeo