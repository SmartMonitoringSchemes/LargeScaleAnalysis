# Download a local copy of the anchoring mesh.
from argparse import ArgumentParser

from fetchmesh.mesh import AnchoringMesh


def main():
    parser = ArgumentParser()
    parser.add_argument("filename", nargs=1)
    args = parser.parse_args()

    mesh = AnchoringMesh.from_api()
    mesh.to_json(args.filename[0])

if __name__ == "__main__":
    main()
