# Simulation study of Local Projections, VARs, and related estimators

Matlab code for large-scale simulation studies of impulse response estimators, including Local Projections (LPs), Vector Autoregressions (VARs), and several variants of these

**Reference:**
[Li, Dake](https://github.com/dake-li), [Mikkel Plagborg-Møller](https://www.mikkelpm.com), and [Christian K. Wolf](https://www.christiankwolf.com/) (2024), "Local Projections vs. VARs: Lessons From Thousands of DGPs" (:page_facing_up:[paper](Documents/lp_var_simul.pdf), :bar_chart:[supplement](Documents/lp_var_simul_supplement.pdf))

Tested in: Matlab R2023a on Windows 10 PC (64-bit)

## Contents

**[Documents](Documents):** Paper, supplement, and documentation
- [lp_var_simul.pdf](Documents/lp_var_simul.pdf): Main paper
- [lp_var_simul_supplement.pdf](Documents/lp_var_simul_supplement.pdf): Online supplement
- [lp_var_simul_companion.pdf](Documents/lp_var_simul_companion.pdf): Technical documentation

**[Estimation_Routines](Estimation_Routines):** General-purpose impulse response estimation functions
- [BVAR_est.m](Estimation_Routines/BVAR_est.m): Bayesian VAR ([Giannone, Lenza & Primiceri, 2015](https://doi.org/10.1162/REST_a_00483))
- [LP_est.m](Estimation_Routines/LP_est.m): Least-squares LP (with optional bias correction as in [Herbst & Johanssen, 2023](https://edherbst.net/research/pdfs/hj_lp-revised.pdf))
- [LP_shrink_est.m](Estimation_Routines/LP_shrink_est.m): Penalized LP ([Barnichon & Brownlees, 2019](https://www.mitpressjournals.org/doi/full/10.1162/rest_a_00778))
- [SVAR_est.m](Estimation_Routines/SVAR_est.m): Least-squares VAR (with optional bias correction as in [Pope, 1990](https://doi.org/10.1111/j.1467-9892.1990.tb00056.x))
- [SVAR_IV_est.m](Estimation_Routines/SVAR_IV_est.m): Least-squares SVAR-IV
- [VAR_avg_est.m](Estimation_Routines/VAR_avg_est.m): VAR model averaging ([Hansen, 2016](https://www.ssc.wisc.edu/~bhansen/papers/var.html))

**[DFM](DFM):** Simulation study based on encompassing Dynamic Factor Model (DFM)
- [run_dfm.m](DFM/run_dfm.m): Main file for executing simulations
- [run_combine.m](DFM/run_combine.m): Combines simulation data files from multiple DGPs
- [Reporting](DFM/Reporting): Folder with files that produce results figures and tables
  - [run_plot_dgp.m](DFM/Reporting/run_plot_dgp.m): Plots and tables of DGP summary statistics (Table 1 and Figure 1 in the paper)
  - [run_plot_loss.m](DFM/Reporting/run_plot_loss.m): Plots of bias, standard deviation, median bias, and interquartile range (Figures 2-3 and 10-11 in the paper)
  - [run_plot_tradeoff.m](DFM/Reporting/run_plot_tradeoff.m): Plots of head-to-head loss function comparisons and best method (Figures 4-9 in the paper)
  - [settings_shared.m](DFM/Reporting/settings_shared.m): Shared settings for plotting functions
- [Settings](DFM/Settings): Folder with simulation settings
- [Subroutines](DFM/Subroutines): Folder with data for calibrating the DFM and various functions for simulation and computing summary statistics
  - [SW_DFM_Estimation](DFM/Subroutines/SW_DFM_Estimation): DFM code and data adapted from [Lazarus, Lewis, Stock & Watson (2018)](https://doi.org/10.1080/07350015.2018.1506926)

## Acknowledgements
We rely on BVAR code by [Domenico Giannone, Michele Lenza & Giorgio Primiceri](http://faculty.wcas.northwestern.edu/gep575/GLPreplicationWeb.zip), penalized LP code by [Regis Barnichon & Christian Brownlees](https://drive.google.com/drive/folders/1Fjzw-U3hjIl467KXywRqeQod2jdHOmDo?usp=sharing), as well as VAR model averaging code by [Bruce Hansen](https://www.ssc.wisc.edu/~bhansen/progs/var.html). We have slightly modified these sets of code to improve their run-time without affecting their numerical output. We also use Dynamic Factor Model code and data by [Eben Lazarus, Daniel Lewis, Jim Stock & Mark Watson](http://www.princeton.edu/~mwatson/ddisk/LLSW_ReplicationFiles_071418.zip).

Plagborg-Møller acknowledges that this material is based upon work supported by the NSF under [Grant #2238049](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2238049), and Wolf does the same for [Grant #2314736](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2314736).
