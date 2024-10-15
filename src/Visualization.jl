function visualize_2d(model::TrussModel; show_ground = true, show_labels = false, show_shade = true)

    #extract node positions
    nodes = node_positions(model)

    #flatten the vectors of start/end node indices of each element [[istart, iend], [istart,iend]...]
    element_indices = vcat(Asap.nodeids.(model.elements)...)

    #turn them into vectors of Point3's from GLMakie
    pts = Point2.(eachrow(nodes))
    els = pts[element_indices]

    #get the axial forces
    f = Asap.axial_force.(model.elements)

    #find the maximum magnitude force
    fmax = maximum(abs.(f))

    #set the colorrange based on these forces
    cr = (-1, 1) .* fmax

    #figure
    fig = Figure()
    ax = Axis(
        fig[1,1],
        aspect = DataAspect()
    )

    #get rid of axes and grid lines
    hidedecorations!(ax)
    hidespines!(ax)

    if show_ground
        lines!([0., 20.], [0., 0.], color = :black, linewidth = 4)
    end

    #plot the element lines
    #replace color = f with color = :black to get all black lines
    linesegments!(
        els,
        color = f,
        # color = :black,
        colorrange = cr,
        linewidth = 2,
        colormap = cgrad([:red, :lightgray, :blue])
    )


    support_check = [all(node.dof[1:2]) ? :white : :black for node in model.nodes]

    #plot the nodes
    scatter!(
        pts,
        color = support_check,
        strokecolor = :black,
        strokewidth = 2
    )

    if show_labels

        element_labels = ["E$i" for i = 1:model.nElements]
        node_labels = ["N$i" for i = 1:model.nNodes]

        e_midpoints = Point2.(midpoint.(model.elements))

        text!(pts, text = node_labels, color = :black)
        text!(e_midpoints, text = element_labels, color = :gray)

    end

    #return the figure
    return fig
end

function make_plane_mesh(origin, normal, lu = .1, lv = .1; unitx = GeometryBasics.Vec3([1,0,0]), tol = 1e-6)
    @assert length(origin) == length(normal) == 3

    o = Point3(origin)
    n = Vec3(normalize(normal))

    x_alignment = norm(n - unitx)

    u = x_alignment < tol ? Vec3([0,1,0]) : normalize(cross(n, unitx))
    v = normalize(cross(n, u))

    span1 = lu * u
    span2 = lv * v

    vertices = [
        o + span1 + span2,
        o + span1 - span2,
        o - span1 - span2,
        o - span1 + span2
    ]

    faces = [GeometryBasics.TriangleFace([1,2,3]), GeometryBasics.TriangleFace([1,3,4])]

    return GeometryBasics.Mesh(vertices, faces)

end