from scipy import ndimage
import xarray as xr


def summ_stats(slc, da):
    """
    Dictionary of summary statistics for each slice
    """
    mile = da[slc]["Abs_PM"]
    minute = da[slc]["Abs_PM"]
    d = {"minute_min": minute.min(),
            "minute_max": minute.max(),
            "Abs_PM_min": mile.min(),
            "Abs_PM_max": mile.max(),
            "pixels": da[slc].sum(),
            }
    return {k: float(v) for k, v in d.items()}


def process_image(da):
    """
    Process a single DataArray
    """
    lbl = ndimage.label(da)
    slices = ndimage.find_objects(lbl[0])
    return [summ_stats(slc, da) for slc in slices]


if __name__ == "__main__":

    import numpy as np

    a = xr.DataArray(np.zeros((10, 11)), dims = ("Abs_PM", "minute"))
    a[3:5, 3:5] = 1
    a[4, 5] = 1
    a[7:9, 7] = 1

    out = process_image(a)
