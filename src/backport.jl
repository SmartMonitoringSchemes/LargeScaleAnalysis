# Backport from Julia 1.5
# https://github.com/JuliaLang/julia/commit/53f9d1c86a6666ce1487e503b849c9fb43fdb532
using Base: hasfastin, haslength

const FASTIN_SET_THRESHOLD = 70

function isdisjoint(l, r)
    function _isdisjoint(l, r)
        hasfastin(r) && return !any(in(r), l)
        hasfastin(l) && return !any(in(l), r)
        haslength(r) && length(r) < FASTIN_SET_THRESHOLD && return !any(in(r), l)
        return !any(in(Set(r)), l)
    end
    if haslength(l) && haslength(r) && length(r) < length(l)
        return _isdisjoint(r, l)
    end
    _isdisjoint(l, r)
end
