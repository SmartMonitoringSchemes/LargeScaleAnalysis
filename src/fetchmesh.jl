module Fetchmesh

using PyCall

export AnchoringMesh, MeasurementType, load_asntree, load_traceroute

const AnchoringMesh = PyNULL()
const MeasurementType = PyNULL()

function __init__()
    copy!(AnchoringMesh, pyimport("fetchmesh.mesh").AnchoringMesh)
    copy!(MeasurementType, pyimport("fetchmesh.meta").MeasurementType)

    py"""
from fetchmesh.asn import ASNDB
from fetchmesh.io import AtlasRecordsReader
from fetchmesh.transformers import TracerouteMapASNTransformer, TracerouteFlatIPTransformer

def load_traceroute(filename, asntree):
    transformers = [
        TracerouteMapASNTransformer(asntree),
        TracerouteFlatIPTransformer(as_set = True, drop_dup = True, drop_late = True, extras_fields = ['asn'], insert_none = False)
    ]
    with AtlasRecordsReader(filename, transformers=transformers) as rdr:
        # Sort is important here!
        # There is no guarantee that the data is sorted inside the file.
        return sorted(list(rdr), key=lambda x: x["timestamp"])
"""
end

load_asntree(filename) = py"ASNDB.from_file($filename).radix_tree()"
load_traceroute(filename, asntree) = py"load_traceroute($filename, $asntree)";

end