ROOT = ../../../
FILE_LIST = apb_slave.f

VCS_OPTIONS = +vcs+lic+wait -Mupdate -debug -full64 =fsdb

# --- test vector ---
frbm_example.out:
	$(ROOT)/logical/cmsdk_ahb_fileread_masters/bin/fm2conv.pl -busWidth=32 -infile=frbm_example.fri -out frbm_example.out

all_vcs: frbm_example.out
	vcs -R -ntb_opts dtm $(VCS_OPTIONS) -f ../logical/$(FILE_LIST)
