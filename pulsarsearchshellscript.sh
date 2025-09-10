#!/bin/bash
#pulsar_search_pipeline

#SBATCH --job-name=pulsar_search
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ak00021@mix.wvu.edu
#SBATCH --export=ALL
#SBATCH --mem=32G

echo 'Code started at:'
date 
sleep 120

###....This code will loop through given number of files specified in the 'file_array' below and perform search routine for each file thoroughly without having us to edit or make 
###....changes. Remember all the filterbank file mentioned below in the file_array should be copied/available in the directory where we run this script. So, once we run this script
###....it will automatically run the search routine through given number of multiple files and save *.fft, cands.txt(candidate file) and prepfold plot files in the directory that will 
###....named accordingly as the filenames in the file_array.


file_array=("GaiaNSCand0020_60710_pow.fil" "GaiaNSCand0020_60711_pow.fil" "GaiaNSCand0020_60712_pow.fil")

for file in "${file_array[@]}";
do
  	filename=$(echo "$file")

	python example_your_trim.py $filename

	first_name=$(echo "$filename" | cut -d'.' -f1)

	last_name="_trimmed.fil"

	trimmed_file="$first_name$last_name"

	#echo "$trimmed_file"

	python example_your_mask.py  $trimmed_file

	## Applying rfifind to get rid of RFI. 

	rfi_file=killchan_your.txt

	rfifind -time 1.0 -ignorechan $rfi_file -o GAIA $trimmed_file

	## Clearing birdies

	prepdata -nobary -o GAIA_topo_DM0.00 -dm 0.0 -ignorechan $rfi_file -mask GAIA_rfifind.mask  $trimmed_file

	realfft GAIA_topo_DM0.00.dat

	accelsearch -numharm 2 -zmax 0 GAIA_topo_DM0.00.dat

	python create_birds_file.py GAIA_topo_DM0.00_ACCEL_0

	mkdir birdies

	mv GAIA_topo_* ./birdies/

	cp GAIA_rfifind.inf GAIA.inf

	makezaplist.py GAIA.birds

	zapbirds -zap -zapfile GAIA.zaplist birdies/GAIA_topo_DM0.00.fft

	DDplan.py -o GAIA_DDplan -w $trimmed_file

	##### This block of code below is adding mask and ignorechan into dedispersion file generated from DDplan.py command above. ########3

	add_dedisp="dedisp_"

	edit_file_name="$add_dedisp$trimmed_file"

	trim_file_extension=$(echo "$edit_file_name" | cut -d'.' -f1)

	extension_name=".py"

	dispersion_file="$trim_file_extension$extension_name"

	#echo "$dispersion_file"

	file_path="/minish/ak00021/project_PRESTOPRACTICE/$dispersion_file"

	gawk -i inplace '{gsub(/prepsubband/, "prepsubband -mask GAIA_rfifind.mask -ignorechan killchan_your.txt"); print}' $file_path

	################# Block ends here ############

	python $file_path

	ls *.dat | xargs -n 1 realfft

	ls GaiaNSCand0020_*_pow_trimmed_DM*fft | xargs -n 1 rednoise 

	bary_val=$(prepdata -o tmp $trimmed_file | grep Average)  # Only to calculate barycentric value below and tmp.* files should be deleted before running code below.

	rm -rf tmp.*

	barycentric_velocity=$(echo "$bary_val" | awk -F'= ' '{print $2}')

	#echo "$barycentric_velocity"

	ls GaiaNSCand0020_*_pow_trimmed_DM*_red.fft | xargs -n 1 zapbirds -zap -zapfile GAIA.zaplist -baryv $barycentric_velocity

	ls GaiaNSCand0020_*_pow_trimmed_DM*_red.fft | xargs -n 1 accelsearch -numharm 8 -baryv $barycentric_velocity


	python ACCEL_sift.py > cands.txt

	single_pulse_search.py *.dat

	dm_value=$(awk '/GaiaNSCand/ {c++; if(c==1) print $2}' cands.txt)

	period_value=$(awk '/GaiaNSCand/ {c++; if(c==1) print $8}' cands.txt)

	prepfold -n 64 -mask GAIA_rfifind.mask -ignorechan killchan_your.txt -p $period_value -dm $dm_value  $trimmed_file

	rm -rf *_ACCEL_* *.singlepulse GAIA* killchan_your.txt  *.dat *.inf *_red birdies/

	dir_name=$(echo "$filename" | awk -F'p' '{print $1}')

	#echo "$dir_name"

	mkdir $dir_name

	mv *.fft cands.txt  $file_path *.pfd* *_singlepulse.ps slurm* "$dir_name"

done
echo 'The code completes and stops at: '
date 
sleep 120




