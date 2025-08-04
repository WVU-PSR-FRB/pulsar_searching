"""
This script produces a version of the input file that
trims of the first and last few minutes of the data.
This is *NOT* strictly necessary, though CHIME data are 
known to contain a full transit of the source, include 
a few minutes where the source is about to transit into the
field of view and several minutes where it transits out of the
field of view.
"""

import matplotlib.pyplot as plt
import numpy as np
import your
import sys

### read in and trim data of interest.
filename = (sys.argv)[1]
filename_base = filename.split(".")[0]

your_obj = your.Your((sys.argv)[1])
your_wtr = your.Writer(
    your_obj,
    nstart  = 610351,
    nsamp   = 1048576,
    outdir  = "./",
    outname = f"{filename_base}_trimmed",
)
your_wtr.to_fil()
