module LargeScaleAnalysis

using CodecZstd
using DataStructures
using JSON
using HDPHMM
using IterTools
using LightGraphs

import Base: getindex, hasfastin, in, iterate, length, range, reduce, to_index
import JSON: parsefile

export DataSegmentationModel,
    LabelledTraceroute,
    TracerouteRecord,
    labelize,
    Segment,
    group,
    maprange,
    segments,
    parsefile,
    bidirectional_mapping,
    AnchoringMesh,
    measurement_mapping,
    Changepoint,
    changepoints,
    closest_multiple

include("backport.jl")
include("io.jl")
include("traceroute.jl")
include("segments.jl")
include("fetchmesh.jl")
include("utilities.jl")

end
