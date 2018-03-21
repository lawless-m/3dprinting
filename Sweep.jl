#!/usr/local/bin/julia 

if get(ENV, "OS", "") == "Windows_NT"
	push!(LOAD_PATH, "K:/3dp/3dprinting")
end

using Mesh

n = Net()

function p(n, v)
	@printf("%s (%0.2f, %0.2f, %0.2f)\n", n, v.x, v.y, v.z)
end

function profile(path::Vertex)
	[(1,2), (2,1.6), (3,1.75), (3.5, 2), (4,2.2), (5,2), (6,1), (7,0.2), (8, 0.2), (9, 0.8), (9.3, 1), (10, 1.6), (10.3, 2), (10.7, 3), (10.8, 4), (10.9,5), (10.7, 6), (10.5, 7), (10,7.2), (9,7.3), (8, 7.1), (7.8, 7), (7.3, 6), (7,5.8), (6.4, 5), (6,4.75), (5,4), (4,4.5), (3.5, 5), (3.2, 6), (3,6.3), (2.3,7), (2,7.01), (1,6), (0.7, 5), (0.5,4), (0.6, 3)]
end

function arc(t::Real)
	Vertex(- 90 * cos(2pi*t), -40sin(2pi*t), 90 * sin(4pi*t))
end

function normal(t::Real, tstep::Real, fpath)
	t0 = fpath(t - tstep)
	t1 = fpath(t)
	t2 = fpath(t + tstep)
	normalize((t1 - t0) + (t2 - t1))
end

function solid(n::Net, slices::Real, fpath, slicer) 
	tstep = 1/(slices-1)
	for t in 0.0:tstep:1.0
		path = fpath(t)
		pathv = vertex!(n, path)
		ve = pathv
		pts = slicer(path) 
		steps = length(pts)
		nom = normal(t, tstep, arc)
		ay = angleZX(nom)
		if ay < 0
			ay += 2pi
		end
		for (x,y) in pts
			v = rotate(x, y, 0, 0, ay, 0)
			ve = vertex!(n, v + path)
		end
		
		#= 
			CAP
		=# 

		if t > 0
			face!(n, pathv+1, pathv+steps, pathv-1)
			face!(n, pathv+1, pathv-steps, pathv-1)
			for s in 1:steps-1
				face!(n, pathv+1+s, pathv+s, pathv-1+s-steps)
				face!(n, pathv-1+s-steps, pathv+s-steps, pathv+1+s )
			end
		end
	end
end	

function sqr(path::Vertex)
	[(-1,-1), (1,-1), (1,1), (-1,1), ], Vertex(0.,0.,0.), Vertex(0.,0.,1)
end

function sweep(steps)
	solid(n, steps, arc, profile)
	STL_ASCII(n, "sweep.stl")
	println("Swept")
end


sweep(144)