# This C source code accompanies with Image Processing On Line (IPOL) article
# "Total Variation Inpainting using Split Bregman" at 

#     http://www.ipol.im/pub/algo/g_tv_inpainting/

# This source code produces a command line program tvinpaint, which performs 
# total variation regularized image inpainting.

# Usage: tvinpaint <D> <lambda> <input> <inpainted>
#
# where <D>, <input>, and <inpainted> are BMP images (JPEG, PNG, or TIFF files
# can also be used if the program is compiled with libjpeg, libpng, and/or 
# libtiff).  The argument <lambda> is a positive scalar specifying the fidelity
# weight.


# -----------------------------------------------------------------------------

tvreg.{c,h}     Implements TvRestore() the main routine for the split Bregman
dsolve.h        Implements DSolve(), which solves the d subproblem
usolve_gs.h     Implements UGaussSeidelVaryingLambda() for the u subproblem
tvregopt.h      Utility and options handling functions for TvRestore()

TV Inpainting
=============

The highlight of this source code is the implementation of total variation 
(TV) regularized image inpainting using the split Bregman algorithm.  This is
an outline of how the inpainting is performed in the tvinpaint.c code:


main(), tvinpaint.c:73      (Program begins here)

    The input image and mask are read with ReadImage().

    Inpaint() is called to perform the inpainting.

    The inpainted image is written with WriteImage().



Inpaint(), tvinpaint.c:151

    Solver parameters are set and the mask is converted to spatially-
    varying lambda(x),

        lambda(x) = { 0,        x in D,
                    { lambda,   x not in D.

    TvRestore() is called to perform the inpainting.



TvRestore(), tvreg.c:98

This routine is a generic solver for TV image restoration problems.  In 
addition to inpainting, it can perform denoising and deconvolution with
several noise models.  Since we are performing inpainting with a Gaussian
noise model, the flags "UseZ" and "DeconvFlag" are both false.

Algorithmic state is saved tvregsolver struct "S" (defined in tvregopt.h:95).
S includes the current solution u, d, dtilde of the minimization problem and
algorithm parameters in Opt.  S is used to pass information between solver
subroutines.

    First, TvRestoreChooseAlgorithm() is called to set algorithm flags.

    Memory is allocated and initialized.

    The main loop for the split Bregman iteration is on lines 261-281:

        DSolve() is called to solve the d subproblem (implemented in 
        dsolve.h).

        USolveFun() calls the u-subproblem solver, UGaussSeidelVaryingLambda()
        (implemented in usolve_gs.h).        

        (Since the noise model is Gaussian, ZSolveFun() is not used.)

        PlotFun() calls TvRestoreSimplePlot() to display the solution progress
        on the screen (implemented in tvregopt.h:146).

    Clean up.

/** @brief Default fidelity weight */
#define TVREGOPT_DEFAULT_LAMBDA         25
/** @brief Default convegence tolerance */
#define TVREGOPT_DEFAULT_TOL            1e-3
/** @brief Default penalty weight on the d = grad u constraint */
#define TVREGOPT_DEFAULT_GAMMA1         5
/** @brief Default penalty weight on the z = u constraint */
#define TVREGOPT_DEFAULT_GAMMA2         8
/** @brief Default maximum number of Bregman iterations */
#define TVREGOPT_DEFAULT_MAXITER        100

# -----------------------------------------------------------------------------

def Inpaint(image u, image f, image D, num Lambda)
{
    tvregopt *Opt = NULL;
    const long NumPixels = ((long)f.Width) * ((long)f.Height);
    num *Red = D.Data;
    num *Green = D.Data + NumPixels;
    num *Blue = D.Data + 2*NumPixels;
    long n, k;
    int Success = 0;
    
    if(!(Opt = TvRegNewOpt()))
    {
        fprintf(stderr, "Memory allocation failed\n");
        return 0;
    }
    
    memcpy(u.Data, f.Data, sizeof(num)*f.Width*f.Height*f.NumChannels);
    
    /* Convert the mask into spatially-varing lambda */       
    for(n = 0; n < NumPixels; n++)
        if(0.299*Red[n] + 0.587*Green[n] + 0.114*Blue[n] > 0.5)
        {
            D.Data[n] = 0;          /* Inside of the inpainting domain */
            
            /* Set u = 0.5 within D */
            for(k = 0; k < u.NumChannels; k++)
                u.Data[n + k*NumPixels] = 0.5;
        }
        else
            D.Data[n] = Lambda;    /* Outside of the inpainting domain */
    
    TvRegSetVaryingLambda(Opt, D.Data, D.Width, D.Height);
    TvRegSetMaxIter(Opt, 250);
    TvRegSetTol(Opt, (num)1e-5);
    
    /* TvRestore performs the split Bregman inpainting */
    if(!TvRestore(u.Data, f.Data, f.Width, f.Height, f.NumChannels, Opt))
    {
        fprintf(stderr, "Error in computation.\n");
        goto Catch;
    }    
    
    Success = 1;
Catch:
    TvRegFreeOpt(Opt);
    return Success;
}


# ****************************************************************************


# ****************************************************************************


# ****************************************************************************


# ****************************************************************************


# ****************************************************************************
