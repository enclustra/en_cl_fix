#Cleanup transcript
transcript file ./Dummy.transcript
file delete ./Transcript.transcript
transcript file ./Transcript.transcript
transcript on

#Compile Files
vcom -quiet -work work -2008 ../vhdl/src/en_cl_fix_pkg.vhd
vcom -quiet -work work -2008 ../vhdl/tb/en_cl_fix_pkg_tb.vhd

#run-tb
vsim -quiet work.en_cl_fix_pkg_tb
run -all
quit -sim

#Check if errors occured
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