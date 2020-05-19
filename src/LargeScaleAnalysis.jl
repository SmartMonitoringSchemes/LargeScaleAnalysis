module LargeScaleAnalysis

using CodecZstd
using DataStructures
using JSON
using HDPHMM
using LightGraphs

import Base: getindex, hasfastin, in, iterate, length, range, reduce, to_index
import JSON: parsefile

export DataSegmentationModel, LabelledTraceroute, TracerouteRecord, labelize,Segment, group, maprange, segments, parsefile, bidirectional_mapping, Fetchmesh

include("backport.jl")
include("io.jl")
include("traceroute.jl")
include("segments.jl")
include("fetchmesh.jl")

end