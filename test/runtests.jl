using Test
using LargeScaleAnalysis

@testset "nd-json" begin
    v1 = parsefile(Vector{Dict}, "./1042404_6098.ndjson")
    v2 = parsefile(Vector{Dict}, "./1042404_6098.ndjson.zst")
    @test v1 == v2
end
