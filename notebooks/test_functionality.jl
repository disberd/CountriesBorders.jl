### A Pluto.jl notebook ###
# v0.19.24

using Markdown
using InteractiveUtils

# ╔═╡ 379d2a96-e432-11ed-370e-8f118ff32591
begin 
	import Pkg
	Pkg.activate(Base.current_project())
	using Revise
	using CountriesBorders
end

# ╔═╡ acbb7521-0f55-48fc-9b83-e208f5225ffe
extract_countries(;continent = "asia")

# ╔═╡ Cell order:
# ╠═379d2a96-e432-11ed-370e-8f118ff32591
# ╠═acbb7521-0f55-48fc-9b83-e208f5225ffe
