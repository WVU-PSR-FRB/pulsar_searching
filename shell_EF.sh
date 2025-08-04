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

python example_your_trim.py GaiaNSCand0020_60632_pow.fil
#python example_your_mask.py GaiaNSCand0020_60624_pow_trimmed.fil

## Applying rfifind to get rid of RFI. 


#rfifind -time 1.0 -ignorechan killchan_your.txt -o GAIA GaiaNSCand0020_60624_pow_trimmed.fil

## Clearing birdies

#prepdata -nobary -o GAIA_topo_DM0.00 -dm 0.0 -ignorechan ./killchan_your.txt -mask GAIA_rfifind.mask GaiaNSCand0020_60624_pow_trimmed.fil
#realfft GAIA_topo_DM0.00.dat
#accelsearch -numharm 2 -zmax 0 GAIA_topo_DM0.00.dat
#python create_birds_file.py GAIA_topo_DM0.00_ACCEL_0
#mkdir birdies
#mv GAIA_topo_* ./birdies/

#cp GAIA_rfifind.inf GAIA.inf
#makezaplist.py GAIA.birds
#zapbirds -zap -zapfile GAIA.zaplist birdies/GAIA_topo_DM0.00.fft
#DDplan.py -o GAIA_DDplan -w GaiaNSCand0020_60624_pow_trimmed.fil

#python dedisp_GaiaNSCand0020_60624_pow_trimmed.py

#ls *.dat | xargs -n 1 realfft
#ls GaiaNSCand0020_*_pow_trimmed_DM*fft | xargs -n 1 rednoise 
#ls GaiaNSCand0020_*_pow_trimmed_DM*_red.fft | xargs -n 1 zapbirds -zap -zapfile GAIA.zaplist -baryv -5.528805e-05
#ls GaiaNSCand0020_*_pow_trimmed_DM*_red.fft | xargs -n 1 accelsearch -numharm 8 -baryv -5.528805e-05
#python ACCEL_sift.py > cands.txt

#single_pulse_search.py *.dat

echo 'The code completes and stops at: '
date 
sleep 120

