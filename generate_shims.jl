#!/usr/bin/env julia
if length(ARGS) != 4
    throw(ArgumentError("""
        wrong number of arguments. Usage:
            julia generate_shims.jl binary jll_package jll_func binpath
            """))
end

binary, jll_package, jll_func, yggbindir = ARGS

const LIBPATH_ENV = Sys.islinux() ? "LD_LIBRARY_PATH" : "DYLD_FALLBACK_LIBRARY_PATH"

code = """
import $(jll_package)

$(jll_package).$(jll_func)() do f
    # Print out the full path to the executable
    println(f)

    # Configure env
    env = Dict{String,String}()
    ## PATH
    env["PATH"] = ENV["PATH"]
    ## LD_LIBRARY_PATH
    env["$(LIBPATH_ENV)"] = ENV["$(LIBPATH_ENV)"]

    # Git requires some extra variables
    if "$(binary)" == "git"
        artifact_root = dirname(dirname(f))
        ## Add libcurl to libpath
        curl_libdir = dirname(Git_jll.LibCURL_jll.libcurl_path)
        env["$(LIBPATH_ENV)"] = "\$(curl_libdir):\$(env["$(LIBPATH_ENV)"])"
        ## Set GIT_EXEC_PATH
        env["GIT_EXEC_PATH"] = joinpath(artifact_root, "libexec", "git-core")
        ## Set GIT_TEMPLATE_DIR
        env["GIT_TEMPLATE_DIR"] = joinpath(artifact_root, "share", "git-core", "templates")
        ## Set GIT_SSL_CAINFO
        env["GIT_SSL_CAINFO"] = joinpath(dirname(Sys.BINDIR), "share", "julia", "cert.pem")
    end

    # Htop requires an extra variable
    if "$(binary)" == "htop"
        env["TERMINFO_DIRS"] = joinpath(Htop_jll.Ncurses_jll.artifact_dir, "share", "terminfo")
    end

    # Print env to stdout
    for k in sort(collect(keys(env)))
        print(k, "=\\\"", env[k], "\\\" ")
    end
    println()

    # Configure args
    args = String[]

    # npm is just an argument to node
    if "$(binary)" == "npm"
        push!(args, "\\\"", NodeJS_16_jll.npm, "\\\"")
    end

    # Print args to stdout
    for arg in args
        print(arg)
    end
end
"""

exepath, env, args = strip.(split(read(`$(Base.julia_cmd()) -e $code`, String), '\n'))

shimpath = joinpath(yggbindir, binary)
mkpath(dirname(shimpath))
open(shimpath, "w") do io
    print(io, """
        #!/bin/bash
        $(env) exec -a "\$0" $(basename(exepath)) $(args) "\$@"
        """)
end

# chmod +x
chmod(shimpath, filemode(shimpath) | 0o111)
