# Detect zstandard compression header
function iszstandard(filename)
    read(filename, 4) == [0x28, 0xb5, 0x2f, 0xfd]
end

# nd-json
function parsefile(::Type{Vector{Dict}}, filename)
    if iszstandard(filename)
        open(f -> map(JSON.parse, eachline(ZstdDecompressorStream(f))), filename)
    else
        open(f -> map(JSON.parse, eachline(f)), filename)
    end
end