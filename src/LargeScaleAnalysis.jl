module LargeScaleAnalysis

import Base: getindex, length, to_index
using DataStructures: DefaultDict

export Segment, group, segments

struct Segment
    state::Int
    range::UnitRange{Int}
end

length(s::Segment) = length(s.range)
to_index(s::Segment) = to_index(s.range)
to_index(ss::Vector{Segment}) = vcat((s.range for s in ss)...)

function group(segments::Vector{Segment})
    groups = DefaultDict{Int,Vector{Segment}}(() -> Segment[])
    for segment in segments
        push!(groups[segment.state], segment)
    end
    groups
end

function segments(A::AbstractVector)
    idxs = findall(A[2:end] .!= A[1:end-1])
    idxs = vcat([0], idxs, [length(A)])
    map(zip(idxs[1:end-1] .+ 1, idxs[2:end])) do (start, stop)
        Segment(A[start], start:stop)
    end
end

end
