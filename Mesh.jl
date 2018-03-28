module Mesh

export Vertex, angleXY, angleYX, angleYZ, angleZY, angleXZ, angleZX, rotate, translate, transformVerts, Edge, Face, Net, vertex!, face!, STL_ASCII, STL

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

function angle(x,y) 
	# atan2(y,x) - take point (x,y) - angle from x axis to point
	if x == y == 0
		0.0
	else
		atan2(y,x)
	end
end

function angleXY(v::Vertex)
	# project onto plane XY, angle from X axis to point		
	angle(v.x, v.y)
end

function angleYX(v::Vertex)
	# project onto plane XY, angle from Y axis to point		
	angle(v.y, v.x)
end

function angleYZ(v::Vertex)
	# project onto plane YZ, angle from Y axis to point
	angle(v.y, v.z)
end

function angleZY(v::Vertex)
	# project onto plane YZ, angle from Z axis to point
	angle(v.z, v.y)
end

function angleXZ(v::Vertex)
	# project onto plane XZ, angle from X axis to point
	angle(v.x, v.z)
end

function angleZX(v::Vertex)
	# project onto plane XZ, angle from Z axis to point
	angle(v.z, v.x)
end

function rotate(v::Vertex, a::Vertex)
	if abs(a.x) > 0
		v = Vertex(v.x, v.y * cos(a.x) - v.z * sin(a.x), v.y * sin(a.x) + v.z * cos(a.x))
	end
	if abs(a.y) > 0
		v = Vertex(v.z * sin(a.y) + v.x * cos(a.y), v.y, v.z * cos(a.y) - v.x * sin(a.y))
	end
	if abs(a.z) > 0
		v = Vertex(v.x * cos(a.z) - v.y * sin(a.z), v.x * sin(a.z) + v.y * cos(a.z), v.z)
	end
	v
end

function rotate(x::Real, y::Real, z::Real, xa::Real, ya::Real, za::Real)
	rotate(Vertex(x,y,z), Vertex(xa, ya, za))
end

function rotate(v::Vertex, xa::Real, ya::Real, za::Real)
	rotate(v, Vertex(xa, ya, za))
end

function rotate(x::Real, y::Real, z::Real, v::Vertex)
	rotate(Vertex(x,y,z), v)
end

function translate(v::Vertex, t::Vertex)
	v+t
end


struct Edge
	From::Integer
	To::Integer
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
	push!(n.Faces, Face(Edge(v1, v2), Edge(v2, v3), Edge(v3, v1)))
end

function transformVerts(n::Net, f, vs::Integer, ve::Integer)
	n.Vertices[vs:ve] = map(f, n.Vertices[vs:ve])
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
		abf = n.Vertices[f.AB.From]
		abt = n.Vertices[f.AB.To]
		bct = n.Vertices[f.BC.To]
		@printf(io, "facet normal 0 0 0\n\touter loop\n\t\tvertex %e %e %e\n\t\tvertex %e %e %e\n\t\tvertex %e %e %e\nendloop\n", abf.x, abf.y, abf.z, abt.x, abt.y, abt.z, bct.x, bct.y, bct.z)
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
