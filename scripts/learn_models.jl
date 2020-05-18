import Pkg
Pkg.activate(@__DIR__)

using CodecZstd
using ConjugatePriors: NormalInverseChisq
using Distributions
using Glob
using HDPHMM
using HMMBase
using JSON
using Missings
using ProgressMeter
using Random

@show Threads.nthreads()

function load_results(file)
    _, ext = splitext(file)
    if ext == ".zst"
        return open(file) do f
            map(JSON.parse, eachline(ZstdDecompressorStream(f)))
        end
    else
        return open(file) do f
            map(JSON.parse, eachline(f))
        end
    end
end

function prior(data)
    obs_med, obs_var = robuststats(Normal, data)
    tp = TransitionDistributionPrior(
        Gamma(1, 1/0.01),
        Gamma(1, 1/0.01),
        Beta(500, 1)
    )
    op = DPMMObservationModelPrior{Normal}(
        NormalInverseChisq(obs_med, obs_var, 1, 10),
        Gamma(1, 0.5)
    )
    BlockedSamplerPrior(1.0, tp, op)
end

function prepare(results; interval = 240)
    index, data = Int64[], allowmissing(Float64[])
    for result in results
        push!(index, result["timestamp"])
        push!(data, result["min"] > 0 ? result["min"] : missing)
    end
    resample_interval(index, data, 240)
end

function infer(data; L = 10, LP = 5)
    config = MCConfig(
        init = KMeansInit(L),
        iter = 200,
        verb = false
    )
    chains = HDPHMM.sample(BlockedSampler(L, LP), prior(data), data, config = config)
    result = select_hamming(chains[1])
    result[2], HMM(result[4], result[2])
end

function process(file)
    Random.seed!(2020)

    @info "Processing $file"
    results = load_results(file)
    index, data = prepare(results)
    seq, hmm = infer(data)

    output_file = "$(file).model.json"
    output = Dict(:index => index, :data => data, :state => seq, :model => hmm)

    @info "Writing $(output_file)"
    write(output_file, json(output))
end

function retry(f; retries = 1)
    n = 0
    while n < retries
        try
            return f(nothing)
        catch
            n += 1
            stacktrace(catch_backtrace())
        end
    end
    nothing
end

function main(args)
    HDPHMM.enablemissing(1.0)

    files = glob("*.ndjson", args[1])
    @show length(files)
    
    p = Progress(length(files))

    Threads.@threads for file in files
        retry(_ -> process(file))
        next!(p)
    end
end

main(ARGS)
