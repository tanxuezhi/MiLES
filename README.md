[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1237837.svg)](https://doi.org/10.5281/zenodo.1237837)

# MiLES v0.6
## Mid-Latitude Evaluation System

Oct 2014  - Aug 2018

by P. Davini (ISAC-CNR, p.davini@isac.cnr.it)

Acknowledgements to:
G. Di Capua (PIK), J. von Hardenberg (ISAC-CNR), 
I. Mavilia (ISAC-CNR), E. Arnone (ISAC-CNR)

------------------------------

## WHAT IS MiLES?

**MiLES** is a diagnostic suite based on R and CDO aimed at estimating the properties of Northern Hemisphere mid-latitude climate in Global Climate Models and Reanalysis datasets. It has been originally thought for EC-Earth GCM output and then it has been extended to any model or Reanalysis datasets. 
It requires only daily 500hPa Northern Hemisphere geopotential height data and produces NetCDF4 outputs and climatological figures over the chosen time period and season.
Before performing analysis, data are preprocessed and interpolated on a common 2.5x2.5 grid using CDO.  
Model data can be compared against ECMWF ERA-Interim Reanalysis for a standard period (1979-2017) or with any other MiLES-generated data.

Current version includes:

1. 	**1D Atmospheric Blocking**: *Tibaldi and Molteni (1990)* index for Northern Hemisphere.
   	 Computed at fixed latitude of 60N, with delta of -5,-2.5,0,2.5,5 deg, fiN=80N and fiS=40N.
   	 Full timeseries and climatologies are provided in NetCDF4 Zip format.

2. 	**2D Atmospheric blocking**: following the index by *Davini et al. (2012)*.
	It is a 2D version of *Tibaldi and Molteni (1990)* for Northern Hemisphere
	atmospheric blocking evaluating meridional gradient reversal at 500hPa.
	It includes also Meridional Gradient Index and Blocking Intensity index
	and Rossby wave orientation index, computing both Instantenous Blocking and Blocking Events frequency.
	Blocking Events definition allows the estimation of the blocking duration.
	A supplementary Instantaneous Blocking index with the GHGS2 conditon is also evaluted. 
	Full timeseries and climatologies are provided in NetCDF4 Zip format.

3. 	**Z500 Empirical Orthogonal Functions**: Based on EOFs computed by R using SVD.
	First 4 EOFs for North Atlantic (over the 90W-40E, 20N-85N box), North Pacific (140E-80W, 20N-85N) and Northern Hemisphere (20N-85N).
	North Atlantic Oscillation, Pacific North American pattern and Arctic Oscillation are thus computed. 
	Figures showing linear regression of PCs on monthly Z500 are provided.
	PCs and eigenvectors, as well as the variances explained are provided in NetCDF4 Zip format.

4.	**North Atlantic Weather Regimes**: following k-means clustering of 500hPa geopotential height.
	4 weather regimes over North Atlantic (80W-40E 30N-87.5N) are evaluted using 
	anomalies from daily seasonal cycle. North Atlantic first EOFs (retaining the 80% of variance) are computed to reduce 
	the phase-space dimension and then k-means clustering using Hartigan-Wong algorithm with k=4 is computed. 
	Cluster assignment is performed analyzing positions of absolute minima and maxima.
	Figures report patterns and frequencies of occurrence. NetCDF4 Zip data are saved.
	*Only 4 regimes and DJF season is supported so far.*

5. 	**Meandering Index (beta)** : following the index introduced by *Di Capua and Coumou (2016)*. It evaluates the 
	waviness of the atmosphere (i.e. the length of the longest isopleth) at a reference latitude of 60N. Original
	code can be found at https://github.com/giorgiadicapua/MeanderingIndex. NetCDF4 Zip data are saved 
	but no figures are provided.

----------------

## MAIN NOTES & REFERENCES

Be aware that this is a free scientific tool in continous development, then it may not be free of bugs. Please report any issue on the GitHub portal.

Please cite **MiLES** in your publication: *"P. Davini, 2018: MiLES - Mid Latitude Evaluation System. Zenodo. http://doi.org/10.5281/zenodo.1237837"*. If you want to cite a specific version of check on [Zenodo](https://zenodo.org/record/1237838#.WumJkNOFPUI) which DOI to use. 
Extra references to specific indices are:

a). *"Tibaldi S. and Molteni F. 1990. On the operational predictability of blocking. Tellus A 42(3): 343–365, doi:10.1034/j.1600- 0870.1990.t01- 2- 00003.x."* in case you  use the 1D blocking index.

b). *"Davini  P., C. Cagnazzo, S. Gualdi, and A. Navarra, 2012: Bidimensional Diagnostics, Variability, and Trends of Northern Hemisphere Blocking. J. Climate, 25, 6496–6509, doi: 10.1175/JCLI-D-12-00032.1."* in case you use the 2D blocking index.

c). *"Di Capua G. and Coumou D. 2016: Changes in meandering of the Northern Hemisphere circulation. Environ. Res. Lett. 11 (2016) 094028 doi:10.1088/1748-9326/11/9/094028"* in case you use the Meandering Index.

**MiLES v0.4** has been also included in the [ESMValTool Package](https://github.com/ESMValGroup/ESMValTool/releases).  

----------------

## SOFTWARE REQUIREMENTS

- a. R version > 3.0
- b. CDO version > 1.6.5 (1.8 at least for complete GRIB support), compiled with netCDF4
- c. Compiling environment (gcc)

IMPORTANT: there are 5 R packages (ncdf4, maps, PCICt, akima and mapproj) needed to run **MiLES**.
You have to run `Rscript config/installpack.R` as first step in order to install the packages.
If everything runs fine, their installation is performed by an automated routine that brings the user through the standard web-based installation.
Packages are also included in **MiLES** and can be installed offline setting `web=0` in the script.
- _ncdf4_ provides the interface for NetCDF files.
- _maps_ provides the world maps for the plots (version >= 3.0 )
- _PCICt_ provides the tools to handle 360-days and 365-days calendars (from model data). 
- _akima_ provides the interpolation for map projections.
- _mapproj_ provides a series of map projection that can be used.

If you are aware of other way to implement this 5 passages without using those packages, please contact me.

-----------------

## HOW TO

### Configuration

Before running **MiLES** the 5 above-mentioned R packages should installed.

Two configuration scripts control the program options:
1. 	`config/config_$MACHINE.sh` controls the properties of your environment. 
	It should be set accordingly to your local configuration. Two template `.tmpl` files for Unix and Mac Os X machines are provided. 
	It is a trivial configuration, needing only information on CDO/R paths and some folders definition.
    	_IMPORTANT_: this file also includes the directory tree for your model NetCDF files and the expected input files format. 
    	It's extremely important that you **create OUR OWN config file**: in this way it will not be overwritten by further pull.   
2.	`config/R_config.R` controls the plot properties. If everything is ok, you should not touch this file.
	However, from here you can change in the properties of the plots (as figure size, palettes, axis font, etc.).
	Also output file format and map projection can be specified here if you do not use the wrapper (see later).
	Figures are extremely basic: they can be produced in pdf, png and eps format.

### Running with the wrapper

The simplest way to run **MiLES** is executing in bash environment `./wrapper_miles.sh`. 
Options as seasons, which EOFs compute, reference dataset or file output format as well as the map projection to use
can specified at this stage: here below a list of the variables that can be set up

#### Key variables
- `machine` -> the name of the configuration file of your local machine.
- `dataset_exp` -> identifier for the dataset used to create files and paths structure.
- `expid_exp` ->  identifier for the experiment type used to create files and paths structure (set to `NO` if you do not want to use it)
- `ens_list` -> identifier for the ensemble members used to create files and paths structure (set to `NO` if you do not want to use it). This can be written as a list in order to evaluate multiple ensembles. In case of multiple ensemble members an extra ensemble mean will be produced by the wrapper only for blocking data.
IMPORTANT: the three above-mentioned vars are the core of the CMIP data structure and they have been introduced to this aim.
- `year1_exp` and `year2_exp` -> the years on which MiLES will run. 
- `std_clim` -> can be `true` to use standard ERAI 1979-2017 climatology, `false` for custom comparison.
- `seasons` -> specify one or more of the 4 standard seasons using 3 characters (DJF-MAM-JJA-SON). Use `ALL` to cover the full year. Otherwise, use 3 character for each month divided by an underscore to create your own season (e.g. `Jan_Feb_Mar`). This last functionality is under testing.
- `dataset_ref`, `expid_ref`, `ens_ref`, `year1_ref` and `year2_ref`  -> in analogy to the main variables, these controls the experiment to be compared when `std_clim=false` is set. 

#### Secondary variables
- `teles` -> A list of one or teleconnection patterns. `NAO`,`PNA` or `AO` for standard EOFs over North Atlantic and Northern Hemisphere. Custorm regions can be specifieds as `lon1_lon2_lat1_lat2`.
- `output_file_type` -> pdf, eps or png figures format.
- `map_projection` -> set `no` for standard plot (fast). Use `azequalarea` for polar plots (default). All projection from mapproj R package are supported (but not all of them have been tested).
- `doeof`,`doblock`,`doregime`,`domeand` -> set to true or false in order to run some specific sections only.
- `doforceanl`,`doforcedata` -> set to true or false in order to rerun the analysis or the data preparation (respectively).

### Other Scripts 

The chain of scripts will be executed as a sequence by the wrapper.
However, each **MiLES** script can be run autonomously from command line providing the correct sequence of arguments.
R-based scripts are written as R functions and thus can be called inside R if needed.  

* `z500_prepare.sh`. **MiLES** is based on a pre-processing of data. 
This script expects geopotential height data (daily or higher frequency) in a single folder: from v0.5 it is able to identify 500hPa data among other levels. The code interpolates data on a 2.5x2.5 grid, performs daily averaging and selects the NH only. Most importantly, it organizes the data structure in order to make it handable by **MiLES**. It produces a single NetCDF4 Zip files with all the data available. A check is performed in order to avoid useless run of the script: if your file is corrupted you can use the `doforcedata` flags to overwrite it. You can use both geopotential or geopotential height data, the former will be automatically converted. To simplify the analysis by R, the CDO `-a` is used to set an absolute time axis in the data.  

* `Rbased_eof_fast.R` and `Rbased_eof_figures.R`. EOFs are computed using Singular Value Decompositon (SVD) R function by the former script, while the latter provides the figures. EOFs signs for the main EOFs are checked in order to maintain consistency with the reference dataset.

* `blocking_fast.R` and `blocking_figures.R`. Blocking analysis is performed by the first R script. The second provides the figures. 
Both the Davini et al. (2012) and the Tibaldi and Molteni (1990) blocking index are computed and plotted by these scripts, as well a wide set of related dignostics. See Davini et al. (2012) for more details.

* `regimes_fast.R` and `regimes_figures.R`. Weather regimes analysis is performed by the first R script. 
It also tries to assign the right weather regimes to its name, saving all to NetCDF data. The second provides the figures.

* `meandering_fast.R`. It computes the Meandering Index following the Di Capua and Coumou (2016). No figures are yet provided. 

* `extra_figures_block.R`. This is not called by the wrapper and it provides extra statistics, comparing several experiments with ensemble means, histogram for specific region and Taylor diagrams. 

### Execution times

**MiLES** is pretty fast: on iMac 2017  (MacOS High Sierra 10.13, 3.4 GHz Intel Core i5, 16GB DDR4) 30 years of analysis for a single season takes about (test on v0.6):
- EOFs: 12 seconds
- Blocking: 59 seconds
- Regimes: 28 seconds
- Meandering: 182 seconds
- Figures (together): 20 seconds

Please be aware that issues may arise with large datasets (i.e. larger than 100 years) where the single file approach may be problematic. 
It is recommended in such cases to split the analysis in different subsets. 

------------

## HISTORY

*v0.6 - Aug 2018*
- Introducing the Meandering Index from Di Capua and Coumou (2016)
- CMIP-like (dataset+experiment+ensemble member) data structure is introduced, allowing also for experiment type definition
- Minor updates to the functions variables names, structure and layout
- Packages update
- Beta support for cross-dateline EOFs

*v0.51 - Apr 2018*
- Consolidation of weather regimes functions (shift to variance minimum)
- Improved cluster name assignation
- Improved Netcdf conventions for output files
- Rewritten ncdf.opener function

*v0.5 - Mar 2018*
- Able to detect 500hPa level inside of any geopotential height data
- Improved wrapper with flags to control each section
- Frequency is again plotted on regimes
- Various bug fixing and consolidation
- Improved climatologies (ERAI 1979-2017)

*v0.43 - Feb 2018*
- R-based EOFs script consistent with the MiLES structure
- Rearrange structure of wrapper and config file: now $INDIR is defined in config files (increase portability!)
- Beta support for free month and season selection
- Consistent ensemble members support
- Various bug fixing for NetCDF access
- Improved functions to control path and folders for NetCDF and figures
- Faster daily anomalies computation for weather regimes script
- Variance is again plotted for EOFs
- Template files are provided for Unix and Mac Os X machines

*v0.42 - Dec 2017*
- Inclusion of extra blocking diagnostics (Taylor diagrams, Duration-Events plots, histograms, etc.)
- Ensemble mean for blocking outputs
- Ensemble member support for blocking routine
- Bug fixing for calendar handling 
- 10-day blocking events as new output
- ECMWF data structure support
- Updated climatology (1979-2016)
- Support for Grib files

*v0.41 - Jul 2017*
- Plot bug fixing

*v0.4 - June 2017*
- Tibaldi and Molteni (1990) blocking index is now computed by blocking_fast.R
- Weather regimes based on k-means clustering over North Atlantic is now available.
- Reformulation of input Z500 files, now based on a single NetCDF file: to handle 360-days 
  and 365-day calendar package PCICt is now required.
- Polar projection support: requires mapproj and akima packages. 
- Figures updates and various bug fixing.
- Re-written wrapper to provide dynamic comparison of datasets

*v0.31 - May 2017*
- Comparison of EOFs and Blocking figures with any other MiLES-generated dataset.
- Beta-version of sign-check for main EOFs.
- Reformulation: each script is made by R function + can be run from command line.
- Change folder structure to simplify portability.
- Code consolidation and folder/variable name normalization.

*v0.3 - May 2017*
- Blocking Events definition by Davini et al. (2012) now avaiable.
- Removed dependencies from fields and spam R packages.
- Support for figures format in png, pdf or eps - by J. von Hardenberg.
- Removed dependencies on R-files saving blocking data (using now NetCDF).
- Blocking timeseries available in NetCDF.
- NetCDF4 Zip for blocking output files.
- Support for different model calendar: 30-day, Gregorian and No-Leap-Year.
- ~36x faster linear regression for EOFs (.fit.lm function).
- new ~2x faster largescale.extension.if() function.
- Improved speed in blocking for long timeseries: ~2.5x faster for 30years (predeclaration of arrays).
- Minor bugs in axis legends (removal of image.plot).
- Readme in markdown format.

*v0.2 - Apr 2017*
- Support for Arctic Oscillation.
- External unique configuration file.
- Psuedo-universal adaptability to any model data.
- Automated script for R package installing.
- Adaptation to geopotential/geopotential height data.
- Climatological blocking data are stored in NetCDF.
- Now on GitHUB.

*v0.11 - Mar 2015*
- Update to fast blocking (Blocking2-scheme) computation.

*v0.1 - Oct 2014*
- EOFs and 2D Blocking calculation.
- Basic functions implemented.
- Support for NetCDF4.
- Support for 4 standard season (DJF,MAM,JJA,SON).
- ERAINTERIM comparison via netCDF files.
- Parallelization Z500 extraction.
- Png outputs from PDF.

-----------------

