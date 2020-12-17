#!/usr/bin/env julia
if length(ARGS) != 4
    throw(ArgumentError("""
        wrong number of arguments. Usage:
            julia generate_shims.jl binary jll_package jll_func prefix
            """))
end

binary, jll_package, jll_func, prefix = ARGS

code = """
using $(jll_package)

$(jll_func)() do f
    println(f)
    println(ENV["PATH"])
    print(ENV["LD_LIBRARY_PATH"])
end
"""
exepath, PATH, LD_LIBRARY_PATH = split(read(`$(Base.julia_cmd()) --project=. -e $code`, String), '\n')

@assert basename(exepath) == binary

shimpath = joinpath(prefix, "bin", basename(exepath))
mkpath(dirname(shimpath))
open(shimpath, "w") do io
    print(io, """
        #!/bin/bash
        exec env PATH="$(PATH)" LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)" "$(basename(exepath))" "\$@"
        """)
end
# chmod +x
chmod(shimpath, filemode(shimpath) | 0o111)
