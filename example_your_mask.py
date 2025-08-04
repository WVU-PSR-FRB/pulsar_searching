"""
This script produces a 'kill-chan file', containing indeces of
channels to ignore during searches.
"""


import matplotlib.pyplot as plt
import numpy as np
import your
import sys

### first off, ignore LTE completely and known persistent channels.
### NOTE: 'your' reads in data in reverse-channel order than how they're 
###       read by PRESTO, so account for this when using 'your'.
freqs = np.linspace(800.195, 400.195, 1024)
freqs_true = np.linspace(400.195, 800.195, 1024)
idx_ignore = []
idx_ignore_true = []

for ii in range(1024):
    if freqs[ii] > 710. and freqs[ii] < 770.:
        idx_ignore += [ii]

    if freqs[ii] > 605. and freqs[ii] < 620.:
        idx_ignore += [ii]

    if freqs[ii] > 680. and freqs[ii] < 690.:
        idx_ignore += [ii]

    if freqs_true[ii] > 710. and freqs_true[ii] < 770.:
        idx_ignore_true += [ii]
    
    if freqs_true[ii] > 605. and freqs_true[ii] < 620.:
        idx_ignore_true += [ii]
    
    if freqs_true[ii] > 680. and freqs_true[ii] < 690.:
        idx_ignore_true += [ii]
    
### now read in data one segment at a time.
your_obj = your.Your((sys.argv)[1])
num_spectra = your_obj.your_header.nspectra
num_chan = your_obj.your_header.nchans
num_passes = int(num_spectra / 1024)
data_mean_extracted = np.zeros((num_chan, num_passes))
data_std_extracted = np.zeros((num_chan, num_passes))

for ii in range(num_passes):
    print(f"... extracting chunk {ii+1}")
    nstart = ii * 1024
    data = your_obj.get_data(nstart=nstart, nsamp=1024)
    data = data.T
    data_mean_extracted[:, ii] = np.mean(data, axis=1)
    data_std_extracted[:, ii] = np.std(data, axis=1)

### now determine which channels have large standard deviations
### after removing the known-persistent bad channels.
data_mean = np.mean(data_mean_extracted, axis=1)
data_std = np.std(data_mean_extracted, axis=1)
print(f"min, max: ({data_std_extracted.min()}, {data_std_extracted.max()})")
idx_nonzero = np.where(data_std != 0)[0].tolist()
idx_zero = np.where(data_std == 0)[0].tolist()
data_mean[idx_ignore] = 0
data_std[idx_ignore] = 0
idx_zero_full = np.where(data_std == 0)[0].tolist()
idx_nonzero_full = np.where(data_std != 0)[0].tolist()
std = np.std(data_std[idx_nonzero_full]) * 0.5
idx_std_threshold = np.where(data_std > std)[0]

### if desired, plot derived mean (top) and standard deviation of chanellized data
#plt.subplot(2,1,1)
#plt.plot(data_mean[idx_nonzero_full])
#plt.subplot(2,1,2)
#plt.plot(data_std[idx_nonzero_full])
#plt.plot([0, len(data_std[idx_nonzero_full])], [std, std], "r-")
#plt.show()

# finally,save kill-chan data for use in PRESTO routines.
idx_all = idx_ignore_true + idx_zero + idx_std_threshold.tolist()
fout = open("killchan_your.txt", "w")
fout.write(",".join([str(x) for x in idx_all]) + "\n")
fout.close()
