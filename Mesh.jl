module Mesh

export Vertex, Edge, Face, Net, vertex!, face!, STL_ASCII, STL

struct Vertex
	x::Float32
	y::Float32
	z::Float32
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