ROOT = ../../
FILE_LIST = apb_slave.f

VCS_OPTIONS = -sverilog +vcs+lic+wait +vcs+flush+log -Mupdate +v2k -full64 -debug_access+all -debug_region+cell+encrypt -kdb -lca -timescale=1ns/1ps

# --- test vector ---
frbm_example.out:
	$(ROOT)/logical/cmsdk_ahb_fileread_masters/bin/fm2conv.pl -busWidth=32 -infile=frbm_example.fri -out frbm_example.out

all_vcs: frbm_example.out
	vcs -R -ntb_opts dtm $(VCS_OPTIONS) -f $(FILE_LIST)
