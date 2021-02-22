# Simulation study of Local Projections, VARs, and related estimators

Matlab code for large-scale simulation studies of impulse response estimators, including Local Projections (LPs), Vector Autoregressions (VARs), and several variants of these

**Reference:**
Li, Dake, Mikkel Plagborg-Møller, and Christian K. Wolf (2021), "Local Projections vs. VARs: Lessons From Thousands of DGPs", https://scholar.princeton.edu/mikkelpm/lp_var_simul (paper + online supplement)

Tested in: Matlab R2020a on Windows 10 PC (64-bit)

**Acknowledgements:**
We rely on penalized LP code by [https://github.com/ctbrownlees/MATLAB-package-lproj][Regis Barnichon & Christian Brownless], as well as VAR model averaging code by [https://www.ssc.wisc.edu/~bhansen/progs/var.html][Bruce Hansen]. We have slightly modified both of these sets of codes to improve their run-time without affecting their numerical output.

## Contents

**[Analytical_Illustration](Analytical_Illustration):** Plots for simple analytical illustration
- [plot_tradeoff.m](Analytical_Illustration/plot_tradeoff.m): Figure 1 in the paper
- [plot_indiff.m](Analytical_Illustration/plot_indiff.m): Figure 2 in the paper

**[Estimation_Routines](Estimation_Routines):** General-purpose impulse response estimation functions
- [BVAR_est.m][Estimation_Routines/BVAR_est.m]: Bayesian VAR
- [LP_est.m][Estimation_Routines/LP_est.m]: Least-squares LP
- [LP_shrink_est.m][Estimation_Routines/LP_shrink_est.m]: Penalized LP ([https://www.mitpressjournals.org/doi/full/10.1162/rest_a_00778][Barnichon & Brownlees, 2019])
- [SVAR_est.m][Estimation_Routines/SVAR_est.m]: Least-squares VAR (also does bias correction)
- [SVAR_IV_est.m][Estimation_Routines/SVAR_IV_est.m]: Least-squares SVAR-IV
- [VAR_avg_est.m][Estimation_Routines/VAR_avg_est.m]: VAR model averaging ([https://www.ssc.wisc.edu/~bhansen/papers/var.html][Hansen, 2016])

**[DFM](DFM):** Simulation study based on encompassing Dynamic Factor Model (DFM)
- [run_dfm.m][DFM/run_dfm.m]: Main file for executing simulations
- [Reporting][DFM/Reporting]: Folder with files that produces results figures and tables
  - [run_plot_dgp.m][DFM/Reporting/run_plot_dgp.m]: Plots and tables of DGP summary statistics (Table 1 and Figure 3 in the paper)
  - [run_plot_loss.m][DFM/Reporting/run_plot_loss.m]: Plots of bias, standard deviation, median bias, and interquartile range (Figures 4-5 and 10-11 in the paper)
  - [run_plot_tradeoff.m][DFM/Reporting/run_plot_tradeoff.m]: Plots of head-to-head loss function comparisons and best method (Figures 6-9 in the paper)
  - [settings_shared.m][DFM/Reporting/settings_shared.m]: Shared settings for plotting functions
- [Settings][DFM/Settings]: Folder with simulation settings
- [Subroutines][DFM/Subroutines]: Folder with data for calibrating the DFM and various functions for simulation and computing summary statistics
