# Clean up the transcript
transcript file ""
file delete ./Transcript.transcript
transcript file ./Transcript.transcript
transcript on

# Compile files
vlib lib_en_cl_fix
vcom -quiet -work lib_en_cl_fix -2008 ../vhdl/src/en_cl_fix_pkg.vhd
vcom -quiet -work lib_en_cl_fix -2008 ../vhdl/tb/en_cl_fix_pkg_tb.vhd

# Run the testbench
vsim -quiet lib_en_cl_fix.en_cl_fix_pkg_tb
run -all
quit -sim

# Check if errors occurred
set transcriptFile [open "./Transcript.transcript" r]
set transcriptContent [read "$transcriptFile"]; list
close $transcriptFile
set found [regexp -nocase "###ERROR###" $transcriptContent]
set foundFatal [regexp -nocase {Fatal:} $transcriptContent]
echo $found
echo $foundFatal
if {($found == 1) || ($foundFatal == 1)} {
	echo "!!! ERRORS OCCURED IN SIMULATIONS !!!"
} else {
	echo "SIMULATIONS COMPLETED SUCCESSFULLY"
}

# Close the transcript file
transcript file ""