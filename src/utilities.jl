# Smallest multiple of `x` >= `n`.
closest_multiple(x, n) = x * cld(n, x)