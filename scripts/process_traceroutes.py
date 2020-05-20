from argparse import ArgumentParser
from pathlib import Path

from fetchmesh.asn import ASNDB
from fetchmesh.io import AtlasRecordsReader, AtlasRecordsWriter
from fetchmesh.peeringdb import PeeringDB
from fetchmesh.transformers import (
    TracerouteFlatIPTransformer,
    TracerouteMapASNTransformer,
    TracerouteMapIXTransformer,
)
from tqdm import tqdm


def process_traceroute(filename, suffix, transformers):
    with AtlasRecordsReader(filename, transformers=transformers) as r:
        with AtlasRecordsWriter(filename.with_suffix(suffix)) as w:
            w.writeall(r)


def main():
    parser = ArgumentParser()
    parser.add_argument("--asndb", required=True, help="e.g. rib.20200208.0800.txt")
    parser.add_argument("--path", required=True)
    parser.add_argument("--suffix", default=".processed.json")
    args = parser.parse_args()

    print("Loading ASN database...")
    asntree = ASNDB.from_file(args.asndb).radix_tree()

    print("Loading IX database...")
    ixtree = PeeringDB.from_api().radix_tree()

    transformers = [
        TracerouteMapASNTransformer(asntree),
        TracerouteMapIXTransformer(ixtree),
        TracerouteFlatIPTransformer(
            drop_dup=True,
            drop_late=True,
            extras_fields=["asn", "ix"],
            insert_none=False,
        ),
    ]

    files = list(Path(args.path).glob("*.ndjson"))
    for file in tqdm(files):
        process_traceroute(file, args.suffix, transformers)


if __name__ == "__main__":
    main()
