function generate_canopy(x1::Real, x2::Real, x3::Real, x4::Real; w = 1.0, y_upper_support = 15.0, E = 29e3, Acanopy = 15., Acable = 2.)

    #round x4 to nearest integer
    x4 = Int(round(x4, digits = 0))

    #convert data types for Asap compatibility and assign to positions
    y_lower_support = Float64(x1)

    x_tip = Float64(x2)
    y_tip = Float64(x3)

    n_cables = x4
    @assert n_cables > 0

    #make support nodes
    supp1 = TrussNode([0., y_lower_support, 0.], [false, false, false], :lower_support)
    supp2 = TrussNode([0., y_upper_support, 0.], [false, false, false], :upper_support)

    #canopy nodes
    canopy_vector = [x_tip, y_tip, 0] - supp1.position
    L_canopy = norm(canopy_vector)
    canopy_direction = normalize(canopy_vector) #direction vector of canopy
    canopy_span = L_canopy / n_cables

    canopy_nodes = [TrussNode(canopy_span * canopy_direction * i + supp1.position, [true, true, false], :canopy) for i = 1:n_cables]

    #give the last canopy node a different id
    last(canopy_nodes).id = :tip

    #elements
    canopy_section = TrussSection(Acanopy, E)
    cable_section = TrussSection(Acable, E)

    #canopy elements
    canopy_elements = [TrussElement(supp1, canopy_nodes[1], canopy_section, :canopy)]
    if n_cables > 1
        for i = 1:n_cables-1
            push!(canopy_elements, TrussElement(canopy_nodes[i], canopy_nodes[i+1], canopy_section, :canopy))
        end
    end

    #cable elements
    cable_elements = [TrussElement(supp2, node, cable_section, :cable) for node in canopy_nodes]

    #loads
    P = [0., -w * canopy_span, 0.]
    loads = [NodeForce(node, P) for node in canopy_nodes]

    #last point on canopy only has half the load (due to tributary width)
    last(loads).value = P / 2

    #collect
    nodes = [supp1; supp2; canopy_nodes]
    elements = [canopy_elements; cable_elements]

    #assemble
    model = TrussModel(nodes, elements, loads)

    #solve
    solve!(model)

    return model

end

function generate_canopy(x; w = 1.0, y_upper_support = 15.0, E = 29e3, Acanopy = 15., Acable = 2.)
    return generate_canopy(x...; w = w, y_upper_support = y_upper_support, E = E, Acanopy = Acanopy, Acable = Acable)
end