# Segments

struct Segment
    state::Int
    range::UnitRange{Int}
end

iterate(s::Segment, args...) = iterate(s.range, args...)
length(s::Segment) = length(s.range)
range(s::Segment) = s.range

to_index(s::Segment) = to_index(s.range)
to_index(ss::Vector{Segment}) = vcat((s.range for s in ss)...)

Base.hasfastin(s::Segment) = hasfastin(s.range)
in(item, s::Segment) = in(item, s.range)

maprange(s::Segment, index::Vector{Int}) =
    Segment(s.state, index[s.range.start]:index[s.range.stop])

function group(segments::Vector{Segment})
    groups = DefaultDict{Int,Vector{Segment}}(() -> Segment[])
    for segment in segments
        push!(groups[segment.state], segment)
    end
    groups
end

function segments(A::AbstractVector; closed = false)
    idxs = findall(A[2:end] .!= A[1:end-1])
    idxs = vcat([0], idxs, [length(A)])
    map(zip(idxs[1:end-1] .+ 1, idxs[2:end])) do (start, stop)
        closed && (stop < idxs[end]) && (stop += 1)
        Segment(A[start], start:stop)
    end
end

segments(model::DataSegmentationModel; kwargs...) =
    map(s -> maprange(s, model.index), segments(model.state; kwargs...))
segments(traceroute::LabelledTraceroute; kwargs...) =
    map(s -> maprange(s, traceroute.index), segments(traceroute.label; kwargs...))

function bidirectional_mapping(A, B)
    mapping_ab = Dict(i => Int[] for i = 1:length(A))
    mapping_ba = Dict(j => Int[] for j = 1:length(B))
    for (i, a) in enumerate(A), (j, b) in enumerate(B)
        if !isdisjoint(a, b)
            push!(mapping_ab[i], j)
            push!(mapping_ba[j], i)
        end
    end
    mapping_ab, mapping_ba
end

function bidirectional_mapping(A::Vector{Segment}, B::Vector{Segment})
    mapping_ab, mapping_ba = bidirectional_mapping(range.(A), range.(B))
    Dict(A[k] => [B[i] for i in v] for (k, v) in mapping_ab),
    Dict(B[k] => [A[i] for i in v] for (k, v) in mapping_ba)
end

function reduce(d::Dict{Segment,Vector{Segment}})
    mapping = DefaultDict{Int,Set{Int}}(() -> Set{Int}())
    for (k, v) in d
        isempty(v) && continue
        push!(mapping[k.state], [x.state for x in v]...)
    end
    mapping
end

# Changepoints

struct Changepoint
    state_before::Int
    state_after::Int
    time::Int
end

function changepoints(segments::Vector{Segment})
    map(zip(segments[1:end-1], segments[2:end])) do (before, after)
        Changepoint(before.state, after.state, after.range.start)
    end
end

changepoints(x) = changepoints(segments(x))