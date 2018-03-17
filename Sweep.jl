#!/usr/local/bin/julia 
push!(LOAD_PATH, "K:/3dp/")

using Mesh

n = Net()

function slice2d(rstp::Real, baseradius::Real, path::Vertex)
	r = baseradius + (baseradius/2) * sin(pi * 2path.z/360)
	pts = Vector{Tuple{Real,Real}}()
	for t = rstp:rstp:2pi
		push!(pts, (r * sin(t), r * cos(t)))
	end
	pts
end

function p(n, v)
	@printf("%s (%0.2f, %0.2f, %0.2f)\n", n, v.x, v.y, v.z)
end

function trang(path::Vertex)
[(1,2), (2,1.6), (3,1.75), (3.5, 2), (4,2.2), (5,2), (6,1), (7,0.2), (8, 0.2), (9, 0.8), (9.3, 1), (10, 1.6), (10.3, 2), (10.7, 3), (10.8, 4), (10.9,5), (10.7, 6), (10.5, 7), (10,7.2), (9,7.3), (8, 7.1), (7.8, 7), (7.3, 6), (7,5.8), (6.4, 5), (6,4.75), (5,4), (4,4.5), (3.5, 5), (3.2, 6), (3,6.3), (2.3,7), (2,7.01), (1,6), (0.7, 5), (0.5,4), (0.6, 3)]
end

function arc(t::Real)
	#Vertex(30t,120t^2,80t)
	Vertex(2t,2t,0)
end

function normal(t::Real, tstep::Real, farc)
	t1 = arc(t)
	if t == 0.0
		t0 = arc(t)
	else
		t0 = arc(t - tstep)
	end
	
	if t >= 1.0
		t2 = arc(1.0)
	else
		t2 = arc(t + tstep)
	end
		
	t01 = t1 - t0
	t12 = t2 - t1
	normalize(0.5*(t01 + t12))
end

function solid(n::Net, slices::Real, slicer) 	
	for t in 0.0:1/(slices-1):1.0
		path = arc(t)
		pathv = vertex!(n, path)
		ve = pathv
		pts = slicer(path)
		steps = length(pts)
		for (x,y) in pts
			ve = vertex!(n, path.x+x, path.y+y, path.z)
		end
		
		#= cap
		if path.z < zstp || path.z > 300 - zstp
			face!(n, pathv, pathv+steps, pathv+1)
			for v in pathv+2:pathv+steps
				face!(n, pathv, v-1, v)
			end
		end
		=#
	
		if t > 0.0
			face!(n, pathv+1, pathv+steps, pathv-1)
			face!(n, pathv+1, pathv-steps, pathv-1)
			for s in 1:steps-1
				face!(n, pathv+1+s, pathv+s, pathv-1+s-steps)
				face!(n, pathv-1+s-steps, pathv+s-steps, pathv+1+s )
			end
		end
	end
end	

r = 30.0

# solid(n, 3, z -> slice2d(2pi/5, r, z))
#solid(n, 13, trang)
#STL_ASCII(n, "sweep.stl")

println(normal(0,0.5,arc))


