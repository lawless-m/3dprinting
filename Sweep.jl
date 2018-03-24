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
	[(1,2), (2,1.6), (3,1.75), (3.5, 2), (4,2.2), (5,2), (6,1), (7,0.2), (8, 0.2), (9, 0.8), (9.3, 1), (10, 1.6), (10.3, 2), (10.7, 3), (10.8, 4), (10.9,5), (10.7, 6), (10.5, 7), (10,7.2), (9,7.3), (8, 7.1), (7.8, 7), (7.3, 6), (7,5.8), (6.4, 5), (6,4.75), (5,4), (4,4.5), (3.5, 5), (3.2, 6), (3,6.3), (2.3,7), (2,7.01), (1,6), (0.7, 5), (0.5,4), (0.6, 3)], Vertex(0,0,1)
end

function arc(t::Real)
	Vertex(30 * cos(2pi*t), 0, 30 * sin(2pi*t))
end

function normal(t::Real, tstep::Real, fpath)
	t0 = fpath(t - tstep)
	t1 = fpath(t)
	t2 = fpath(t + tstep)
	normalize((t1 - t0) + (t2 - t1))
end

function solid(origin::Vertex, n::Net, slices::Real, fpath, slicer)
	path = Vertex(0,0,0) # to return end point
	tstep = 1/(slices-1)
	for t in 0.0:tstep:1.0
		path = origin + fpath(t)
		pathv = vertex!(n, path)
		ve = pathv
		ppts, pnom = slicer(path) 
		steps = length(ppts)
		nom = normal(t, tstep, arc)
		@printf("nom %s\n", nom)
		@printf("pnom %s\n", pnom)

		pay = angleZX(pnom)
		ay = angleZX(nom)
		if ay < 0
			ay += 2pi
		end

		ax = angleYZ(nom)
		pax = angleYZ(pnom)
		@printf("t: %0.2f  ax:%d pax:%d ay:%d pay:%d\n\n", t, rad2deg(ax), rad2deg(pax), rad2deg(ay), rad2deg(pay))
		for (x,y) in ppts
			v = rotate(Vertex(x, y, 0), Vertex(0., ay, 0.))
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
	path
end	

function sqr(path::Vertex)
	[(-1,-1), (1,-1), (1,1), (-1,1), ], Vertex(0,0,1)
end

function sweep(steps, multiples=1)
	o = Vertex(0,0,0)
	for k in 1:multiples
		o = solid(o, n, steps, stockp, sqr)
	end
	println(STDERR, o)
	STL_ASCII(n, "stk.stl")
	println("Swept")
end


function stockp(t::Float64)
	r = 10
	x = y = z = 0.0
	function q1(u)
		r+r*cos(pi - pi*u), r*sin(pi - pi*u)
	end
	function q2(u)
		x1,z1 = q1(1.)
		x1 - 0.5 * r * u, z1 -r * u
	end
	function q3(u)
		x2,z2 = q2(1.)
		x2 + r + r*cos(pi - pi*u), z2 + r*-sin(pi - pi*u)
	end
	function q4(u)
		x3, z3 = q3(1.)
		x3 - 0.5r*u, z3 + r*u
	end
		
	
	if t < 0.25
		x,z = q1(4t)
	elseif t < 0.5
		x,z = q2(4*(t-0.25))
	elseif t < 0.75
		x,z = q3(4*(t-0.5))
	else
		x,z = q4(4*(t-0.75))
	end
	z = -z

	Vertex(x,y,z)
end

using SVG
function pathsvg(fname, tstep, fpath)
	s = open(fname, "w+")
	pts = Vector{Tuple{Real,Real}}()
	st = fpath(1.)
	for stch = 0:10
		for t=0:tstep:1
			v = fpath(t)
			push!(pts, (stch*st.x+v.x, stch*st.z+v.z))
		end
	end
	SVG.open(s, 500.,500.)
	SVG.polyline(s, pts, SVG.blackline(3.))
	SVG.close(s)
end

pathsvg("stk.svg", 1/40, stockp)
		
sweep(900, 10)


