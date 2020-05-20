struct TracerouteRecord
    timestamp::Int
    paris_id::Int
    src_addr::String
    dst_addr::String
    from::String
    hops::Vector{Set{String}}
    hops_asn::Vector{Set{Int}}
    hops_ix::Vector{Set{String}}
end

function TracerouteRecord(d::Dict)
    hops = map(Set{String}, d["hops"])
    hops_asn = map(Set{Int}, d["asn"])
    hops_ix = map(Set{String}, d["ix"])
    TracerouteRecord(d["timestamp"], d["paris_id"], d["src_addr"], d["dst_addr"], d["from"], hops, hops_asn, hops_ix)
end

function parsefile(::Type{Vector{TracerouteRecord}}, filename)
    map(TracerouteRecord, parsefile(Vector{Dict}, filename))
end
    
# TODO: TracerouteComparator type instead?
function Base.:≈(a::TracerouteRecord, b::TracerouteRecord)
    # (length(a.hops) != length(b.hops)) && return false
    for (x, y) in zip(a.hops, b.hops)
        # ! If we have one record with [set(), set(), set(), ...]
        # then all records will be equal...
        # (isempty(x) || isempty(y)) && continue
        (isempty(x) && isempty(y)) && continue
        isdisjoint(x, y) && return false
    end
    true
end

struct LabelledTraceroute
    index::Vector{Int}
    label::Vector{Int}
    data::Vector{TracerouteRecord}
end

# TODO: Optimize
function labelize(records::Vector{TracerouteRecord})
    # Build graph
    g = SimpleGraph(length(records))
    for i in 1:length(records)
        for j in i:length(records)
            (records[i] ≈ records[j]) && add_edge!(g, i, j)
        end
    end
    
    # Build labelled traceroute
    index = Int[]
    label = Int[]
    data = TracerouteRecord[]
    for (k, v) in enumerate(connected_components(g))
        for x in v
            push!(index, records[x].timestamp)
            push!(label, k)
            push!(data, records[x])
        end
    end

    perm = sortperm(index)
    LabelledTraceroute(index[perm], label[perm], data[perm])
end
