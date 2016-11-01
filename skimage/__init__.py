"""Image Processing SciKit (Toolbox for SciPy)

``scikit-image`` (a.k.a. ``skimage``) is a collection of algorithms for image
processing and computer vision.

The main package of ``skimage`` only provides a few utilities for converting
between image data types; for most features, you need to import one of the
following subpackages:

Subpackages
-----------
color
    Color space conversion.
data
    Test images and example data.
draw
    Drawing primitives (lines, text, etc.) that operate on NumPy arrays.
exposure
    Image intensity adjustment, e.g., histogram equalization, etc.
feature
    Feature detection and extraction, e.g., texture analysis corners, etc.
filters
    Sharpening, edge finding, rank filters, thresholding, etc.
graph
    Graph-theoretic operations, e.g., shortest paths.
io
    Reading, saving, and displaying images and video.
measure
    Measurement of image properties, e.g., similarity and contours.
morphology
    Morphological operations, e.g., opening or skeletonization.
novice
    Simplified interface for teaching purposes.
restoration
    Restoration algorithms, e.g., deconvolution algorithms, denoising, etc.
segmentation
    Partitioning an image into multiple regions.
transform
    Geometric and other transforms, e.g., rotation or the Radon transform.
util
    Generic utilities.
viewer
    A simple graphical user interface for visualizing results and exploring
    parameters.

Utility Functions
-----------------
img_as_float
    Convert an image to floating point format, with values in [0, 1].
img_as_uint
    Convert an image to unsigned integer format, with values in [0, 65535].
img_as_int
    Convert an image to signed integer format, with values in [-32768, 32767].
img_as_ubyte
    Convert an image to unsigned byte format, with values in [0, 255].

"""

import os.path
import imp
import functools
import warnings
import sys

pkg_dir = os.path.abspath(os.path.dirname(__file__))
data_dir = os.path.join(pkg_dir, 'data')

__version__ = '0.13dev'


# XXX: review this file

try:
    imp.find_module('nose2')
except ImportError:
    def _test(doctest=False, verbose=True):
        """This would run all unit tests, but nose couldn't be
        imported so the test suite can not run.
        """
        raise ImportError("Could not load nose2. Unit tests are not available.")
else:
    def _test(doctest=False, verbose=True):
        """Run all unit tests."""
        import nose2
        import warnings
        args = ['-s', pkg_dir]
        if verbose:
            args.extend(['--verbose'])
        if doctest:
            args.extend(['--with-doctest'])
            # Make sure warnings do not break the doc tests
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                success = nose2.run('skimage', argv=args)
        else:
            success = nose2.run('skimage', argv=args)
        # Return sys.exit code
        if success:
            return 0
        else:
            return 1


# do not use `test` as function name as this leads to a recursion problem with
# the nose test suite
test = _test
test_verbose = functools.partial(test, verbose=True)
test_verbose.__doc__ = test.__doc__
doctest = functools.partial(test, doctest=True)
doctest.__doc__ = doctest.__doc__
doctest_verbose = functools.partial(test, doctest=True, verbose=True)
doctest_verbose.__doc__ = doctest.__doc__


# Logic for checking for improper install and importing while in the source
# tree when package has not been installed inplace.
# Code adapted from scikit-learn's __check_build module.
_INPLACE_MSG = """
It appears that you are importing a local scikit-image source tree. For
this, you need to have an inplace install. Maybe you are in the source
directory and you need to try from another location."""

_STANDARD_MSG = """
Your install of scikit-image appears to be broken.
Try re-installing the package following the instructions at:
http://scikit-image.org/docs/stable/install.html """


def _raise_build_error(e):
    local_dir = os.path.split(__file__)[0]
    if local_dir == "skimage":
        # Picking up the local install: this will work only if the
        # install is an 'inplace build'
        msg = _INPLACE_MSG
    else:
        msg = _STANDARD_MSG
    err_msg = ("{}\n\n"
               "It seems that scikit-image has not been built correctly.\n"
               "{}".format(e, msg))
    raise ImportError(err_msg)

try:
    # This variable is injected in the __builtins__ by the build
    # process. It used to enable importing subpackages of skimage when
    # the binaries are not built
    __SKIMAGE_SETUP__
except NameError:
    __SKIMAGE_SETUP__ = False


if __SKIMAGE_SETUP__:
    sys.stderr.write('Partial import of skimage during the build process.\n')
    # We are not importing the rest of the scikit during the build
    # process, as it may not be compiled yet
else:
    try:
        from ._shared import geometry
        del geometry
    except ImportError as e:
        _raise_build_error(e)
    from .util.dtype import *


del warnings, functools, os.path, imp, sys
