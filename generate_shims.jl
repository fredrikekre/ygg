#!/usr/bin/env julia
if length(ARGS) != 4
    throw(ArgumentError("""
        wrong number of arguments. Usage:
            julia generate_shims.jl binary jll_package jll_func prefix
            """))
end

binary, jll_package, jll_func, prefix = ARGS

const LIBPATH_ENV = Sys.islinux() ? "LD_LIBRARY_PATH" : "DYLD_FALLBACK_LIBRARY_PATH"

code = """
using $(jll_package)

$(jll_func)() do f
    println(f)
    println(ENV["PATH"])
    print(ENV["$(LIBPATH_ENV)"])
end
"""
exepath, PATH, LD_LIBRARY_PATH = split(read(`$(Base.julia_cmd()) --project=. -e $code`, String), '\n')

@assert basename(exepath) == binary

shimpath = joinpath(prefix, "bin", basename(exepath))
mkpath(dirname(shimpath))
open(shimpath, "w") do io
    print(io, """
        #!/bin/bash
        exec env PATH="$(PATH)" $(LIBPATH_ENV)="$(LD_LIBRARY_PATH)" "$(basename(exepath))" "\$@"
        """)
end
# chmod +x
chmod(shimpath, filemode(shimpath) | 0o111)
