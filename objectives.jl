using HW05_4451

#=
x1: vertical position of lower support [ft] ∈ [6, 14]
x2: horizontal position of tip [ft] ∈ [10, 20]
x3: vertical position of tip [ft] ∈ [6, 14]
x4: number of cables ∈ [2, 20] 
=#

"""
J1 should return a proxy measure of structural volume, i.e. ∑|F|L [kip-ft]

the function Asap.axial_force(element::TrussElement) will be useful. So will length(element::TrussElement)
"""
function J1(model::TrussModel)

    # YOUR CODE HERE

    return
end

"""
J2 should return the unshaded length. [ft]

You can access the last node of the canopy by indexing its ID: last_node = model.nodes[:tip][1].
You'll also probably want to use some trigonometry function provided in base Julia: sin(), cos(), etc...
If you're working in degrees, use sind(), cosd(), etc...
"""
function J2(model::TrussModel)

    # YOUR CODE HERE

    return
end

"""
J3 should return the total number of elements required to construct the design.

Note: the canopy can be made from a single element.
"""
function J3(model::TrussModel)

    # YOUR CODE HERE
    
    return
end

"""
composite_objective returns a scalar objective that is a weighed summation of J1-J3

Use this function for part A by making a closure, e.g.:

obj = x -> composite_objective(x, fj1, fj2, fj3)

in conjunction with Nonconvex.jl and NonconvexNLopt.jl
"""
function composite_objective(x, j1factor, j2factor, j3factor)

    model = generate_canopy(x)

    return J1(model) * j1factor + J2(model) * j2factor + J3(model) * j3factor 

end

"""
multiple_objective returns a vector of all 3 objectives, a vector of inequality constraints (Not applicable, so set to 0), and a vector of equality constraints (not applicable, so set to 0)

Use this function for part B in conjunction with Metaheuristics.jl's NSGA2 optimizer. You will need to make another function closure like with the function above.
"""
function multiple_objective(x, j1factor, j2factor, j3factor)

    model = generate_canopy(x)

    return ([J1(model) * j1factor, J2(model) * j2factor, J3(model) * j3factor], [0.], [0.])

end