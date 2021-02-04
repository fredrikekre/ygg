JULIA ?= julia
PREFIX ?= ${HOME}

MAKEFILE:=$(abspath $(firstword $(MAKEFILE_LIST)))
YGGDIR:=$(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))

export YGGDIR
export JULIA_LOAD_PATH=${YGGDIR}/Project.toml:@stdlib

ygg: ${PREFIX}/bin ${PREFIX}/bin/ygg

${PREFIX}/bin:
	mkdir -p $@

${PREFIX}/bin/ygg:
	echo "#!/bin/bash" > ${PREFIX}/bin/ygg
	echo "IFS='-'" >> ${PREFIX}/bin/ygg
	echo "make -f ${MAKEFILE} "'"$$*"' >> ${PREFIX}/bin/ygg
	chmod +x ${PREFIX}/bin/ygg

${YGGDIR}/Project.toml:
	touch ${YGGDIR}/Project.toml

${YGGDIR}/Manifest.toml: ${YGGDIR}/Project.toml
	${JULIA} -e 'import Pkg; Pkg.instantiate()'

## Installation rule for "simple" binaries that need nothing except
## PATH and LD_LIBRARY_PATH set up. Usage:
##     simple-install binary jll_package jll_func
define simple-install

install-$(1): ${PREFIX}/bin/$(1)

${PREFIX}/bin/$(1): ${YGGDIR}/Manifest.toml
	grep -q $(2) ${YGGDIR}/Project.toml || \
	    ${JULIA} -e 'import Pkg; Pkg.add("$(2)")'
	${JULIA} -e 'import Pkg; Pkg.instantiate()'
	${JULIA} ${YGGDIR}/generate_shims.jl $(1) $(2) $(3) ${PREFIX}

uninstall-$(1):
	${JULIA} -e 'import Pkg; try Pkg.rm("$(2)") catch e end'
	rm -f ${PREFIX}/bin/$(1)

update-$(1):
	${JULIA} -e 'import Pkg; Pkg.update("$(2)")'
	${JULIA} ${YGGDIR}/generate_shims.jl $(1) $(2) $(3) ${PREFIX}

endef

$(eval $(call simple-install,ghr,ghr_jll,ghr))
$(eval $(call simple-install,fzf,fzf_jll,fzf))
$(eval $(call simple-install,git-crypt,git_crypt_jll,git_crypt))
$(eval $(call simple-install,git,Git_jll,git))
