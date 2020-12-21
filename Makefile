JULIA ?= julia-master
PREFIX ?= ${HOME}

Project.toml:
	touch Project.toml

Manifest.toml: Project.toml
	${JULIA} --project=. -e 'import Pkg; Pkg.instantiate()'

## Installation rule for "simple" binaries that need nothing except
## PATH and LD_LIBRARY_PATH set up. Usage:
##     simple-install binary jll_package jll_func
define simple-install

$(1): ${PREFIX}/bin/$(1)

${PREFIX}/bin/$(1): Manifest.toml
	grep -q $(2) Project.toml || \
	    ${JULIA} --project=. -e 'import Pkg; Pkg.add("$(2)")'
	${JULIA} --project=. -e 'import Pkg; Pkg.instantiate()'
	${JULIA} --project=. generate_shims.jl $(1) $(2) $(3) ${PREFIX}

clean-$(1):
	${JULIA} --project=. -e 'import Pkg; try Pkg.rm("$(2)") catch e end'
	rm -f ${PREFIX}/bin/$(1)

update-$(1):
	${JULIA} --project=. -e 'import Pkg; Pkg.update("$(2)")'
	${JULIA} --project=. generate_shims.jl $(1) $(2) $(3) ${PREFIX}

endef

$(eval $(call simple-install,ghr,ghr_jll,ghr))
$(eval $(call simple-install,fzf,fzf_jll,fzf))
$(eval $(call simple-install,git-crypt,git_crypt_jll,git_crypt))
$(eval $(call simple-install,git,Git_jll,git))

# TODO: update this list dynamically in simple-install
update: update-fzf update-ghr update-git-crypt update-git
