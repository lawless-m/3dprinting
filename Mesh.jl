module Mesh

export Vertex, angleX, angleZ, angleY, angleXYZ, rotate, Edge, Face, Net, vertex!, face!, STL_ASCII, STL

struct Vertex
	x::Float32
	y::Float32
	z::Float32
end

import Base.show
function show(io::IO,v::Vertex)
       @printf(io,"Vertex(%0.4f, %0.4f, %0.4f)", v.x, v.y, v.z)
end


import Base.+
function +(a::Vertex, b::Vertex)
	Vertex(a.x+b.x, a.y+b.y, a.z+b.z)
end

import Base.-
function -(a::Vertex, b::Vertex)
	Vertex(a.x-b.x, a.y-b.y, a.z-b.z)
end

import Base./
function /(a::Vertex, s::Real)
	Vertex(a.x/s, a.y/s, a.z/s)
end
 
import Base.*
function *(a::Vertex, s::Real)
	Vertex(a.x*s, a.y*s, a.z*s)
end
function *(s::Real, a::Vertex)
	Vertex(a.x*s, a.y*s, a.z*s)
end

import Base.LinAlg.vecdot
function vecdot(v1::Vertex, v2::Vertex)
	vecdot([v1.x, v1.y, v1.z], [v2.x, v2.y, v2.z])
end

import Base.LinAlg.cross
function cross(v1::Vertex, v2::Vertex)
	cross([v1.x, v1.y, v1.z], [v2.x, v2.y, v2.z])
end

 import Base.LinAlg.normalize
 function normalize(v::Vertex)
       n = normalize([v.x, v.y, v.z])
       Vertex(n[1], n[2], n[3])
 end

function angleXY(v1::Vertex, v2::Vertex)
	a = atan2(v2.y,v2.x) - atan2(v1.y,v1.x)
	if isnan(a)
		0.0
	else
		a
	end
end


function angleY(v::Vertex)
	if v.y == v.x == 0
		0.0
	else
		atan2(v.x, v.y)
	end
end


function angleX(v::Vertex)
	if v.y == v.x == 0
		0.0
	else
		atan2(v.y, v.x)
	end
end

function angleZ(v::Vertex)
	if v.x == v.z == 0
		0.0
	else
		atan2(v.x, v.z)
	end
end

function angleXYZ(v::Vertex)
	Vertex(angleX(v), angleY(v), angleZ(v))
end

function rotate(v::Vertex, xa, ya, za)
	if xa > 0
		v = Vertex(v.x, v.y * cos(xa) - v.z * sin(xa), v.y * sin(xa) + v.z * cos(xa))
	end
	if ya > 0
		v = Vertex(v.z * sin(ya) + v.x * cos(ya), v.y, v.z * cos(ya) - v.x * sin(ya))
	end
	if za > 0
		v = Vertex(v.x * cos(za) - v.y * sin(za), v.x * sin(za) + y * cos(ya), v.z)
	end
	v
end

function rotate(x::Real, y::Real, z::Real, xa::Real, ya::Real, za::Real)
	rotate(Vertex(x,y,z), xa, ya, za)
end

struct Edge
	From::Vertex
	To::Vertex
end

struct Face
	AB::Edge
	BC::Edge
	CA::Edge
end
	
struct Net
	Vertices::Vector{Vertex}
	Faces::Vector{Face}
	Edges::Vector{Edge}
	Net() = new(Vector{Vertex}(), Vector{Face}(), Vector{Edge}())
end

function vertex!(n::Net, x::Float64, y::Float64, z::Float64)
	vertex!(n, Vertex(x, y, z))
end

function vertex!(n::Net, x::Real, y::Real, z::Real)
	vertex!(n, Vertex(Float64(x), Float64(y), Float64(z)))
end

function vertex!(n::Net, v::Vertex)
	push!(n.Vertices, v)
	length(n.Vertices)
end

function face!(n::Net, v1::Integer, v2::Integer, v3::Integer)
	push!(n.Faces, Face(Edge(n.Vertices[v1], n.Vertices[v2]), Edge(n.Vertices[v2], n.Vertices[v3]), Edge(n.Vertices[v3], n.Vertices[v1])))
end

function STL_ASCII(n::Net)
	STL_ASCII(n, STDOUT)
end

function STL_ASCII(n::Net, fn::String)
	fid = open(fn, "w+")
	STL_ASCII(n, fid)
	close(fid)
end

function STL_ASCII(n::Net, io::IO)
	println(io, "solid Mesh.jl")
	for f in n.Faces
		@printf(io, "facet normal 0 0 0\n\touter loop\n\t\tvertex %e %e %e\n\t\tvertex %e %e %e\n\t\tvertex %e %e %e\nendloop\n", f.AB.From.x, f.AB.From.y, f.AB.From.z, f.AB.To.x, f.AB.To.y, f.AB.To.z, f.BC.To.x, f.BC.To.y, f.BC.To.z)
	end
	println(io, "endsolid Mesh.jl")
end

function STL(n::Net)
	STL(n, STDOUT)
end

function STL(n::Net, fn::String)
	fid = open(fn, "w+")
	STL(n, fid)
	close(fid)
end

function STL(n::Net, io)
	for k in 1:10
		write(io, Int64(0))
	end
	write(io, Int32(length(n.Faces)))
	for f in n.Faces
		write(io, Float32(0), Float32(0), Float32(0),  f.AB.From.x, f.AB.From.y, f.AB.From.z, f.AB.To.x, f.AB.To.y, f.AB.To.z, f.BC.To.x, f.BC.To.y, f.BC.To.z)
	end
	write(io, Int16(0))
end

### STAHP

end