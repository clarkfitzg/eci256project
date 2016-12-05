import numpy as np

from scipy.sparse.csgraph import connected_components
from scipy.sparse import dok_matrix

from scipy import ndimage

a = np.zeros((10, 10))
a[3:5, 3:5] = 1
a[4, 5] = 1
a[7:9, 7] = 1

b = ndimage.label(a)

ndimage.find_objects(b[0])

# If we want to just get the 2nd one
ndimage.center_of_mass(a, b[0], 2)
