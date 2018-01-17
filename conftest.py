import numpy as np

if np.version.full_version >= '1.14.0':
    np.set_printoptions(legacy='1.13')

# List of files that pytest should ignore
collect_ignore = ["setup.py",
                  "skimage/io/_plugins",
                  "doc/",
                  "tools/",
                  "viewer_examples"]
try:
    import visvis
except ImportError:
    collect_ignore.append("skimage/measure/mc_meta/visual_test.py")
