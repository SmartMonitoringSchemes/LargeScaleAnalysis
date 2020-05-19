import Pkg
Pkg.activate(@__DIR__)

using Glob
using HDPHMM
using JSON
using LargeScaleAnalysis
using Missings
using ProgressMeter
using Random

@show Threads.nthreads()

function prior(data)
    obs_med, obs_var = robuststats(Normal, data)
#     tp = TransitionDistributionPrior(
#         Gamma(1, 1/0.01),
#         Gamma(1, 1/0.01),
#         Beta(500, 1)
#     )
    tp = TransitionDistributionPrior(
        Gamma(2, 10),
        Gamma(100, 10),
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

function process(file)
    Random.seed!(2020)
    output = "$(file).model.json"
    @info "Processing $(file) => $(output)"
    results = parsefile(Vector{Dict}, file)
    index, data = prepare(results)
    result = segment(index, data, prior(data), L = 15, LP = 5, iter = 250)
    write(output, json(result))
end

function main(args)
    HDPHMM.enablemissing(1.0)

    files = glob("*.ndjson", args[1])
    @show length(files)

    p = Progress(length(files))

    Threads.@threads for file in files
        try
            # Retry once, then catch exception
            retry(process)(file)
        catch e
            showerror(stderr, e, catch_backtrace())
        end
        next!(p)
    end
end

main(ARGS)
