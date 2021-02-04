MAKEFILE:=$(abspath $(firstword $(MAKEFILE_LIST)))
YGGDIR:=$(shell dirname $(abspath $(firstword $(MAKEFILE_LIST))))
JULIA ?= julia
# PREFIX ?= ${YGGDIR}/build
YGGBIN ?= ${YGGDIR}/build/bin

export YGGDIR
export JULIA_LOAD_PATH=${YGGDIR}/Project.toml:@stdlib

ygg: ${YGGBIN}/ygg

clean-ygg:
	rm -f ${YGGBIN}/ygg

${YGGBIN}/ygg: ${YGGBIN}
	echo "#!/bin/bash" > ${YGGBIN}/ygg
	echo "IFS='-'" >> ${YGGBIN}/ygg
	echo "make -f ${MAKEFILE} "'"$$*"' >> ${YGGBIN}/ygg
	chmod +x ${YGGBIN}/ygg

${YGGBIN}:
	mkdir -p $@

${YGGDIR}/Project.toml:
	touch ${YGGDIR}/Project.toml

${YGGDIR}/Manifest.toml: ${YGGDIR}/Project.toml
	${JULIA} -e 'import Pkg; Pkg.instantiate()'

## Installation rule for "simple" binaries that need nothing except
## PATH and LD_LIBRARY_PATH set up. Usage:
##     simple-install binary jll_package jll_func
define simple-install

install-$(1): ${YGGBIN}/$(1)

${YGGBIN}/$(1): ${YGGDIR}/Manifest.toml
	grep -q $(2) ${YGGDIR}/Project.toml || \
	    ${JULIA} -e 'import Pkg; Pkg.add("$(2)")'
	${JULIA} -e 'import Pkg; Pkg.instantiate()'
	${JULIA} ${YGGDIR}/generate_shims.jl $(1) $(2) $(3) ${YGGBIN}

uninstall-$(1):
	${JULIA} -e 'import Pkg; try Pkg.rm("$(2)") catch e end'
	rm -f ${YGGBIN}/$(1)

update-$(1):
	${JULIA} -e 'import Pkg; Pkg.update("$(2)")'
	${JULIA} ${YGGDIR}/generate_shims.jl $(1) $(2) $(3) ${YGGBIN}

endef

$(eval $(call simple-install,ghr,ghr_jll,ghr))
$(eval $(call simple-install,fzf,fzf_jll,fzf))
$(eval $(call simple-install,git-crypt,git_crypt_jll,git_crypt))
$(eval $(call simple-install,git,Git_jll,git))
$(eval $(call simple-install,rr,rr_jll,rr))
$(eval $(call simple-install,zstd,Zstd_jll,zstd))
$(eval $(call simple-install,zstdmt,Zstd_jll,zstdmt))
