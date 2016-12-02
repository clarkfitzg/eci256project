"""
Fri Dec  2 14:38:55 PST 2016

Computing the median and taking the difference.
Then write that difference to file.
"""

import os

import pandas as pd
import xarray as xr

datadir = "/home/clark/data/pems/5min80"

fnames = os.listdir(datadir)

dfs = {x: pd.read_csv(datadir + "/" + x, index_col = ["minute", "Abs_PM"])
        for x in fnames}

bigdf = pd.concat(dfs, names = ["day"])

x = bigdf.to_xarray()

diff = x - x.median("day")

diff.to_netcdf("/home/clark/data/pems/I80diffs.nc")
