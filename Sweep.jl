#!/usr/local/bin/julia 

if get(ENV, "OS", "") == "Windows_NT"
	push!(LOAD_PATH, "K:/3dp/3dprinting")
end

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

function normalizer(pts)
	map(t->normalize([t[1], t[2]]), pts)
end

function arc(t::Real)
	Vertex(20 - 20 * cos(2pi*t), 0, 20 * sin(2pi*t))
end

function dist2D(v1::Vertex, v2::Vertex)
	v = v2 - v1
	sqrt(v.x^2+v.y^2)
end

function distance_angle_table_2D(pts)
	dst = Matrix{Float64}(length(pts), length(pts))
	a = Matrix{Float64}(length(pts), length(pts))
	for i in 1:length(pts)
		dst[i,i] = Inf
		a[i,i] = 0
		for j in i+1:length(pts)
			v1 = Vertex(pts[i][1], pts[i][2], 0)
			v2 = Vertex(pts[j][1], pts[j][2], 0)
			d = dist2D(v1, v2)
			v1 = normalize(v1)
			v2 = normalize(v2)
			dst[i, j] = d
			a[i,j] = angle2D(v1, v2)
			dst[j, i] = d
			a[j,i] = -a[i,j]
		end
	end
	(dst, a)
end

function nearest(i, dsts)
	print(findmin(dsts[i,:]))
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
		slicepts, slicectr, slicenorm = slicer(path) 
		steps = length(slicepts)
		nom = normal(t, tstep, arc)
		ay = angleZX(nom)
		for (x,y) in slicepts
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

function vase()
	r = 30.0
	# kind of partial application
	solid(n, 3, z -> slice2d(2pi/5, r, z))
end



function sqr(path::Vertex)
	[(-1,-1), (1,-1), (1,1), (-1,1), ], Vertex(0.,0.,0.), Vertex(0.,0.,1)
end

function sweep()
	solid(n, 9., arc, sqr)
	STL_ASCII(n, "sweep.stl")
	println("Swept")
end

function capping()	
	
# d = distance_angle_table_2D(trang(Vertex(0,0,0)))

	tri = [(1,1), (3,1), (1, 2)]
	
	(d,a) = distance_angle_table_2D(tri)
	
	println(d)
	println(map(rad2deg, a))
	
	for i in 1:size(d,1)
		@printf("i = %d\n", i)
		for j in 1:size(d,1)
			@printf("\t%02d = (%0.2f, %0.2f)\n", j, d[i,j], rad2deg(a[i,j]))
		end
		@printf("\n")
	end
	
	println(findmin(d[1,2:3]))
	
	k = 0
	while k <= size(d, 1)
		(dd, k) = findmin(d[1,k+1:size(d,1)])
		@printf("1 to %d d:%0.2f a:%0.2f\n", k, d[k], rad2deg(a[k]))
		if a[k] < 0
			break
		end
	end
	
	#nearest(3, d)

end

function rotpath()

#=
	n = normal(0.3, 0.1, arc)

	println(n)
	xa = angleX(n)
	ya = angleY(n)
	za = angleZ(n)
	@printf("xa: %0.2f, ya: %0.2f, za: %0.2f\n\n", rad2deg(xa), rad2deg(ya), rad2deg(za))
=#

	n = Vertex(1,1,0)
	println(n)
	xa = angleX(n)
	ya = angleY(n)
	za = angleZ(n)
	@printf("xa: %0.2f, ya: %0.2f, za: %0.2f\n\n", rad2deg(xa), rad2deg(ya), rad2deg(za))


	n = rotate(n, xa, ya, 0)
	println(n)
	xa = angleX(n)
	ya = angleY(n)
	za = angleZ(n)
	@printf("xa: %0.2f, ya: %0.2f, za: %0.2f\n", rad2deg(xa), rad2deg(ya), rad2deg(za))


end

sweep()

tstep = 1/(9-1)
t = 0
for k = 1:3
	a = arc(t)
	n = normal(t, tstep, arc)

	ay= angleZX(n)

	@printf("arc: %s norm: %s angles: %d\n", a, n, rad2deg(ay))
	r = rotate(1,1,0, Vertex(0, ay, 0))
	println(r)
	t += tstep
end

