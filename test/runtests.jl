using Test
using LargeScaleAnalysis

@testset "nd-json" begin
    v1 = parsefile(Vector{Dict}, "./1042404_6098.ndjson")
    v2 = parsefile(Vector{Dict}, "./1042404_6098.ndjson.zst")
    @test v1 == v2
end

@testset "Segment" begin
    @test segments([1]) == [Segment(1, 1:1)]
    @test segments([1,1,1,2,2,2]) == [Segment(1, 1:3), Segment(2, 4:6)]
    A = [1,1,1,2,2,2]
    @test A[segments(A)] == A
    @test A[Segment(1, 1:3)] == [1,1,1]
end

@testset "Changepoint" begin
    @test changepoints([1]) == []
    @test changepoints([1,2]) == [Changepoint(1, 2, 2)]
end

@testset "Utilities" begin
    @test closest_multiple(240, 0) == 0
    @test closest_multiple(240, 1) == 240
    @test closest_multiple(240, 240) == 240
    @test closest_multiple(240, 241) == 480
end