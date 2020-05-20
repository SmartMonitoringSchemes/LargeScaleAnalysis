struct AnchoringMesh
    data::Vector{Tuple{Dict,Dict}}
    function AnchoringMesh(data)
        # Ensure data is sorted (for IterTools.groupby)
        new(sort(data, by = x -> x[1]["probe"]))
    end
end

function parsefile(::Type{AnchoringMesh}, filename)
    obj = JSON.parsefile(filename)
    AnchoringMesh(map(Tuple, obj))
end

function anchor_probe(d::Dict)
    for tag in d["tags"]
        if !isnothing(match(r"^\d+$", tag))
            return parse(Int, tag)
        end
    end
    nothing
end

# Build a mapping msm_id (type1) => msm_id (type2)
# TODO: Cleanup this method...
function measurement_mapping(mesh::AnchoringMesh, af, t1, t2)
    pairs = []
    groups = groupby(x -> anchor_probe(x[2]), mesh.data)
    for group in groups
        p1, p2 = nothing, nothing
        for (target, measurement) in group
            (measurement["af"] != af) && continue
            (measurement["type"] == t1) && (p1 = measurement["id"])
            (measurement["type"] == t2) && (p2 = measurement["id"])
        end
        !isnothing(p1) && !isnothing(p2) && push!(pairs, (p1, p2))
    end
    Dict(pairs)
end