#=
The contents o this file have been mostly taken and adapted from the
[GeoIO.jl](https://github.com/JuliaEarth/GeoIO.jl) package which is licensed
under MIT license.
The corresponding MIT License is copied below:

MIT License

Copyright (c) 2021 Júlio Hoffimann <julio.hoffimann@gmail.com> and contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
=#

# Part from https://github.com/JuliaEarth/GeoIO.jl/blob/8c0eb84223ecf8a8601850f8b7cc27f81a18d68c/src/conversion.jl.
function topoints(geom, is3d::Bool)
  if is3d
    [Point(GI.x(p), GI.y(p), GI.z(p)) for p in GI.getpoint(geom)]
  else
    [Point(GI.x(p), GI.y(p)) for p in GI.getpoint(geom)]
  end
end

function tochain(geom, is3d::Bool)
  points = topoints(geom, is3d)
  if first(points) == last(points)
    # fix backend issues: https://github.com/JuliaEarth/GeoTables.jl/issues/32
    while first(points) == last(points) && length(points) ≥ 2
      pop!(points)
    end
    Ring(points)
  else
    Rope(points)
  end
end

function topolygon(geom, is3d::Bool, fix::Bool)
  # fix backend issues: https://github.com/JuliaEarth/GeoTables.jl/issues/32
  toring(g) = close(tochain(g, is3d))
  outer = toring(GI.getexterior(geom))
  if GI.nhole(geom) == 0
    PolyArea(outer; fix)
  else
    inners = map(toring, GI.gethole(geom))
    PolyArea([outer, inners...]; fix)
  end
end

function _convert(::Type{Point}, ::GI.PointTrait, geom)
  if GI.is3d(geom)
    Point(GI.x(geom), GI.y(geom), GI.z(geom))
  else
    Point(GI.x(geom), GI.y(geom))
  end
end

_convert(::Type{Segment}, ::GI.LineTrait, geom) = Segment(topoints(geom, GI.is3d(geom))...)

_convert(::Type{Chain}, ::GI.LineStringTrait, geom) = tochain(geom, GI.is3d(geom))

_convert(::Type{Polygon}, trait::GI.PolygonTrait, geom) = _convert_with_fix(trait, geom, true)

function _convert(::Type{Multi}, ::GI.MultiPointTrait, geom)
  Multi(topoints(geom, GI.is3d(geom)))
end

function _convert(::Type{Multi}, ::GI.MultiLineStringTrait, geom)
  is3d = GI.is3d(geom)
  Multi([tochain(g, is3d) for g in GI.getgeom(geom)])
end

_convert(::Type{Multi}, trait::GI.MultiPolygonTrait, geom) = _convert_with_fix(trait, geom, true)

_convert_with_fix(::GI.PolygonTrait, geom, fix) = topolygon(geom, GI.is3d(geom), fix)

function _convert_with_fix(::GI.MultiPolygonTrait, geom, fix)
  is3d = GI.is3d(geom)
  Multi([topolygon(g, is3d, fix) for g in GI.getgeom(geom)])
end

# -----------------------------------------
# GeoInterface.jl approach to call convert
# -----------------------------------------

geointerface_geomtype(::GI.PointTrait) = Point
geointerface_geomtype(::GI.LineTrait) = Segment
geointerface_geomtype(::GI.LineStringTrait) = Chain
geointerface_geomtype(::GI.PolygonTrait) = Polygon
geointerface_geomtype(::GI.MultiPointTrait) = Multi
geointerface_geomtype(::GI.MultiLineStringTrait) = Multi
geointerface_geomtype(::GI.MultiPolygonTrait) = Multi

geom2meshes(geom, fix=true) = geom2meshes(GI.geomtrait(geom), geom, fix)
geom2meshes(trait, geom, fix) = _convert(geointerface_geomtype(trait), trait, geom)
geom2meshes(trait::Union{GI.MultiPolygonTrait,GI.PolygonTrait}, geom, fix) = _convert_with_fix(trait, geom, fix)

# Part from https://github.com/JuliaEarth/GeoIO.jl/blob/8c0eb84223ecf8a8601850f8b7cc27f81a18d68c/src/utils.jl
# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

function asgeotable(table, fix)
  cols = Tables.columns(table)
  names = Tables.columnnames(cols)
  gcol = geomcolumn(names)
  vars = setdiff(names, [gcol])
  table = isempty(vars) ? nothing : (; (v => Tables.getcolumn(cols, v) for v in vars)...)
  geoms = Tables.getcolumn(cols, gcol)
  domain = GeometrySet(geom2meshes.(geoms, fix))
  georef(table, domain)
end

# helper function to find the
# geometry column of a table
function geomcolumn(names)
  snames = string.(names)
  gnames = ["geometry", "geom", "shape"]
  gnames = [gnames; uppercasefirst.(gnames)]
  gnames = [gnames; uppercase.(gnames)]
  gnames = [gnames; [""]]
  select = findfirst(∈(snames), gnames)
  if isnothing(select)
    throw(ErrorException("geometry column not found"))
  else
    Symbol(gnames[select])
  end
end

# add "_" to `name` until it is unique compared to the table `names`
function uniquename(names, name)
  uname = name
  while uname ∈ names
    uname = Symbol(uname, :_)
  end
  uname
end

# make `newnames` unique compared to the table `names`
function uniquenames(names, newnames)
  map(newnames) do name
    uniquename(names, name)
  end
end