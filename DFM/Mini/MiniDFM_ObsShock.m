%% LP vs VAR: DFM SIMULATION STUDY
% Dake Li and Christian Wolf
% this version: 12/12/2019

%% HOUSEKEEPING

clc
clear all
close all

path = 'D:\Dake\Princeton\Research\PlagborgMoller_LPVAR\MATLAB_file\Codes';
addpath(genpath([path '/Auxiliary_Functions']))
addpath(genpath([path '/Estimation_Routines']))
cd([path '/DFM/Mini']);
addpath(genpath('../Subroutines'))

rng(1);

%% DGP

%----------------------------------------------------------------
% Set up DGP
%----------------------------------------------------------------

% Mini DFM dimensions

DF_model.n_y = 2; % number of observables

DF_model.n_fac = 2; % number of factor
DF_model.n_lags_fac = 1; % lag order of factor
DF_model.n_lags_uar = 1; % lag order of measurement error

% Mini DFM coefficients

DF_model.Phi       = [-0.8 0.7; 0.1 0.7];
DF_model.Sigma_eta = [1 0.3; 0.5 1.3];

DF_model.Lambda    = [0.7 0.5; 1.2 -0.6];
DF_model.delta     = [0.2; -0.3];
DF_model.sigma_v   = [1; 1];

% ------ special DGP for debug -----------------
% DF_model.n_lags_fac = 5;
% Phi       = [0.3 0.1; 0.2 0.3];
% DF_model.Phi       = [Phi, Phi*0.5, Phi*(-0.3), Phi*(-0.2), Phi*0.8; eye(8), zeros(8,2)];
% DF_model.Sigma_eta = [1 0.3; 0.5 1.3];
% DF_model.Lambda    = [0.7 0.5; 1.2 1];
% DF_model.delta     = [0.2; 0.3];
% DF_model.sigma_v   = [1; 1];
% clear Phi
% -----------------------------------------------------

% IV

DF_model.IV.rho     = 0.1; % IV persistence
DF_model.IV.alpha   = 1; % IV shock coefficient
DF_model.IV.sigma_v = 1; % IV noise

%----------------------------------------------------------------
% Represent as ABCDEF Form
%----------------------------------------------------------------

DF_model.n_s   = size(DF_model.Phi,2);
DF_model.n_eps = size(DF_model.Sigma_eta,2);
DF_model.n_y   = size(DF_model.Lambda,1);
DF_model.n_w   = size(DF_model.delta,1);
DF_model.n_e   = DF_model.n_w * DF_model.n_lags_uar;

DF_model.ABCD = ABCD_fun_DFM(DF_model);

%% SETTINGS

%----------------------------------------------------------------
% Experiment Specification
%----------------------------------------------------------------

% variable selection

settings.specifications.manual_var_select = 1:1:DF_model.n_y; % select all observables
settings.specifications.random_select     = 0; % no randomization in small model
settings.specifications.plot_indx         = 1; % plot the only specification

% shock position

settings.est.shock_pos           = 1; % manually choose which shock to be our true structural shock?
settings.est.shock_optim         = 1; % choose optimal linear combination of shocks?
settings.est.shock_optim_var     = 1; % for which variable in full model to choose optimal linear combination of shocks 

% IRFs of interest

settings.est.IRF_response_var_pos = 2; % interested in IRF of which variable in each specification?
settings.est.IRF_hor              = 20; % maximal horizon (include contemporary)
settings.est.IRF_select           = 1:20; % which IRFs to summarize

% compute R0_sq using VMA representation

settings.est.VMA_nlags = 50;

% number of Monte Carlo draws

settings.simul.n_MC    = 10; % number of Monte Carlo reps
settings.simul.seed    = (1:settings.simul.n_MC)*10 + randi([0,9],1,settings.simul.n_MC); % random seed

% simulation details

settings.simul.T      = 200; % time periods for each simulation
settings.simul.T_burn = 100; % burn-in

%----------------------------------------------------------------
% Estimation Settings
%----------------------------------------------------------------

% choose estimand

settings.est.methods_name = {'svar','svar_corrbias','bvar','lp','lp_penalize','var_avg'}; % choose estimands
settings.est.with_shock   = 1; % shock is observed and ordered first in data?
settings.est.recursive_shock = 0; % not use recursive shock
settings.est.with_IV      = 0; % IV is ordered first in data or used in IV method?

% lag specification

settings.est.est_n_lag      = 1; % estimate number of lags?
settings.est.est_n_lag_BIC  = 0; % use BIC? otherwise use AIC
settings.est.n_lags_fix     = 4; % default number of lags if not estimated
settings.est.n_lags_max     = 20; % maximal lag length for info criteria

% BVAR prior

settings.est.prior.tightMN  = 0.1;
settings.est.prior.decay    = 0.5;
settings.est.prior.sig      = 1;
settings.est.prior.tightUR  = 5;
settings.est.prior.tightC   = 5;
settings.est.prior.tightVar = 0.1;

% LP smoothing

settings.est.lambda        = 0.01; % for lambda = 0 would just do OLS
settings.est.lambdaRange   = [0.1:0.1:2, 3:1:10]; % cross validation grid, scaled up by T
settings.est.irfLimitOrder = 2; % shrink towards polynomial of that order

% VAR model averaging

settings.est.average_store_weight = [2, 11, 20]; % store model weights at which horizon
settings.est.average_max_lags = 1; % include lags up to n_lags_max? otherwise up to estimated lags

%% PREPARATION

%----------------------------------------------------------------
% Select Specifications
%----------------------------------------------------------------

settings.specifications = pick_var_fn(DF_model, settings);

%----------------------------------------------------------------
% Results Placeholder
%----------------------------------------------------------------

settings.est.n_methods = length(settings.est.methods_name);
settings.est.full_methods_name = {'svar','svar_corrbias','bvar','lp','lp_penalize','var_avg'};

for i_method = 1:length(settings.est.full_methods_name)
    thisMethod = settings.est.full_methods_name{i_method};
    eval(['results_irf_' thisMethod ...
        '= NaN(settings.est.IRF_hor,settings.simul.n_MC,settings.specifications.n_spec);']); % IRF_hor*n_MC*n_spec
    eval(['results_n_lags_' thisMethod ...
        '= NaN(settings.simul.n_MC,settings.specifications.n_spec);']); %n_MC*n_spec
end
clear i_method thisMethod

results_lambda_lp_penalize = NaN(settings.simul.n_MC,settings.specifications.n_spec); % n_MC*n_spec
results_weight_var_avg = NaN(2*settings.est.n_lags_max,length(settings.est.average_store_weight),...
    settings.simul.n_MC,settings.specifications.n_spec); % n_models*n_horizon*n_MC*n_spec

%% PRELIMINARY COMPUTATIONS: ESTIMANDS

%----------------------------------------------------------------
% Compute True IRFs in Complete Model
%----------------------------------------------------------------

[DF_model.irf, settings.est.shock_weight] = compute_irfs(DF_model,settings);

%----------------------------------------------------------------
% Compute Degree of Invertibility in Specifications
%----------------------------------------------------------------

DF_model.R0_sq = compute_invert_DFM(DF_model,settings);

%----------------------------------------------------------------
% Compute Persistency of Observables in Specifications
%----------------------------------------------------------------

DF_model.persistency = compute_persist_DFM(DF_model,settings);

%----------------------------------------------------------------
% Compute Target IRF
%----------------------------------------------------------------

DF_model.target_irf = DF_model.irf(settings.est.IRF_select, ...
    settings.specifications.var_select(:,settings.est.IRF_response_var_pos));

%% MONTE CARLO ANALYSIS

for i_MC = 1:settings.simul.n_MC

    if mod(i_MC, 10) == 0
        disp("Monte Carlo:")
        disp(i_MC)
    end

    %----------------------------------------------------------------
    % Generate Data
    %----------------------------------------------------------------

    rng(settings.simul.seed(i_MC));

    data_sim_all = generate_data(DF_model,settings);

    %----------------------------------------------------------------
    % List All Temporary Storage for i_MC in parfor
    %----------------------------------------------------------------
    
    temp_irf_svar = NaN(settings.est.IRF_hor,settings.specifications.n_spec);
    temp_irf_svar_corrbias = NaN(settings.est.IRF_hor,settings.specifications.n_spec);
    temp_irf_bvar = NaN(settings.est.IRF_hor,settings.specifications.n_spec);
    temp_irf_lp = NaN(settings.est.IRF_hor,settings.specifications.n_spec);
    temp_irf_lp_penalize = NaN(settings.est.IRF_hor,settings.specifications.n_spec);
    temp_irf_var_avg = NaN(settings.est.IRF_hor,settings.specifications.n_spec);
    
    temp_n_lags_svar = NaN(1,settings.specifications.n_spec);
    temp_n_lags_svar_corrbias = NaN(1,settings.specifications.n_spec);
    temp_n_lags_bvar = NaN(1,settings.specifications.n_spec);
    temp_n_lags_lp = NaN(1,settings.specifications.n_spec);
    temp_n_lags_lp_penalize = NaN(1,settings.specifications.n_spec);
    temp_n_lags_var_avg = NaN(1,settings.specifications.n_spec);
    
    temp_lambda_lp_penalize = NaN(1,settings.specifications.n_spec);
    temp_weight_var_avg = NaN(2*settings.est.n_lags_max,...
        length(settings.est.average_store_weight),settings.specifications.n_spec);
    
    %----------------------------------------------------------------
    % Selecting Data
    %----------------------------------------------------------------

    for i_spec = 1:settings.specifications.n_spec
        
        data_sim_select = select_data_fn(data_sim_all,settings,i_spec);
    
        %----------------------------------------------------------------
        % IRF Estimation
        %----------------------------------------------------------------

        % VAR with observed shock
        
        if any(strcmp(settings.est.methods_name, 'svar'))
            [temp_irf_svar(:,i_spec),temp_n_lags_svar(1,i_spec)]...
                = SVAR_est(data_sim_select,settings);
        end

        % bias-corrected VAR with observed shock
        
        if any(strcmp(settings.est.methods_name, 'svar_corrbias'))
            [temp_irf_svar_corrbias(:,i_spec),temp_n_lags_svar_corrbias(1,i_spec)]...
                = SVAR_corr_est(data_sim_select,settings);
        end

        % Bayesian VAR with observed shock
        
        if any(strcmp(settings.est.methods_name, 'bvar'))
            [temp_irf_bvar(:,i_spec),temp_n_lags_bvar(1,i_spec)]...
                = BVAR_est(data_sim_select,settings);
        end

        % LP with observed shock

        if any(strcmp(settings.est.methods_name, 'lp'))
            [temp_irf_lp(:,i_spec),temp_n_lags_lp(1,i_spec)]...
                = LP_est(data_sim_select,settings);
        end

        % shrinkage LP with observed shock

        if any(strcmp(settings.est.methods_name, 'lp_penalize'))
            [temp_irf_lp_penalize(:,i_spec),temp_n_lags_lp_penalize(1,i_spec), temp_lambda_lp_penalize(1,i_spec)]...
                = LP_shrink_est(data_sim_select,settings);
        end

        % VAR model averaging with observed shock
        
        if any(strcmp(settings.est.methods_name, 'var_avg'))
            [temp_irf_var_avg(:,i_spec),temp_n_lags_var_avg(1,i_spec), temp_weight_var_avg(:,:,i_spec)]...
                = VAR_avg_est(data_sim_select,settings);
        end
        
    end
    
    %----------------------------------------------------------------
    % Move Results to Permanent Storage in parfor
    %----------------------------------------------------------------
    
    results_irf_svar(:,i_MC,:) = temp_irf_svar;
    results_irf_svar_corrbias(:,i_MC,:) = temp_irf_svar_corrbias;
    results_irf_bvar(:,i_MC,:) = temp_irf_bvar;
    results_irf_lp(:,i_MC,:) = temp_irf_lp;
    results_irf_lp_penalize(:,i_MC,:) = temp_irf_lp_penalize;
    results_irf_var_avg(:,i_MC,:) = temp_irf_var_avg;
    
    results_n_lags_svar(i_MC,:) = temp_n_lags_svar;
    results_n_lags_svar_corrbias(i_MC,:) = temp_n_lags_svar_corrbias;
    results_n_lags_bvar(i_MC,:) = temp_n_lags_bvar;
    results_n_lags_lp(i_MC,:) = temp_n_lags_lp;
    results_n_lags_lp_penalize(i_MC,:) = temp_n_lags_lp_penalize;
    results_n_lags_var_avg(i_MC,:) = temp_n_lags_var_avg;
    
    results_lambda_lp_penalize(i_MC,:) = temp_lambda_lp_penalize;
    results_weight_var_avg(:,:,i_MC,:) = temp_weight_var_avg;

end

% clear temporary storage

for i_method = 1:length(settings.est.full_methods_name)
    thisMethod = settings.est.full_methods_name{i_method};
    eval(['clear temp_irf_' thisMethod ';']);
    eval(['clear temp_n_lags_' thisMethod ';']);
end
clear temp_lambda_lp_penalize temp_weight_var_avg
clear i_MC i_spec data_sim_all data_sim_select i_method thisMethod

%% SUMMARIZE RESULTS

%----------------------------------------------------------------
% Wrap up Results, Pick out Target IRF
%----------------------------------------------------------------

% wrap up results from parallel loop

for i_method = 1:settings.est.n_methods
    
    thisMethod = settings.est.methods_name{i_method};
    eval(['results.irf.' thisMethod '= results_irf_' thisMethod ';']);
    eval(['results.n_lags.' thisMethod '= results_n_lags_' thisMethod ';']);
    
end

if any(strcmp(settings.est.methods_name, 'lp_penalize'))    
    results.lambda.lp_penalize = results_lambda_lp_penalize;
end

if any(strcmp(settings.est.methods_name, 'var_avg'))
    results.weight.var_avg = results_weight_var_avg;
end

for i_method = 1:length(settings.est.full_methods_name)
    thisMethod = settings.est.full_methods_name{i_method};
    eval(['clear results_irf_' thisMethod ' results_n_lags_' thisMethod ';']);
end

clear results_lambda_lp_penalize results_weight_var_avg
clear i_method thisMethod

% store IRF only at selected horizons

for i_method = 1:settings.est.n_methods
    
    thisMethod = settings.est.methods_name{i_method};
    eval(['results.irf.' thisMethod '= results.irf.' thisMethod '(settings.est.IRF_select,:,:);']);
    
end

clear i_method thisMethod

%----------------------------------------------------------------
% Compute Mean-Squared Errors, Bias-Squared, Variance
%----------------------------------------------------------------

% compute MSE, Bias2, VCE for each horizon and each specification

for i_method = 1:settings.est.n_methods
    
    thisMethod = settings.est.methods_name{i_method};
    
    eval(['results.MSE.' thisMethod '= squeeze(mean((results.irf.' thisMethod ...
        ' - permute(DF_model.target_irf,[1 3 2])).^2, 2));']);
    
    eval(['results.BIAS2.' thisMethod '= (squeeze(mean(results.irf.' thisMethod ...
        ', 2)) - DF_model.target_irf).^2;']);
    
    eval(['results.VCE.' thisMethod '= squeeze(var(results.irf.' thisMethod ', 0, 2));']);
    
end

clear i_method thisMethod

% % compare MSE, Bias2, VCE with benchmark method
% 
% results.compare.MSE = NaN(settings.est.IRF_hor,settings.est.n_methods);
% results.compare.BIAS2 = NaN(settings.est.IRF_hor,settings.est.n_methods);
% results.compare.VCE = NaN(settings.est.IRF_hor,settings.est.n_methods);
% 
% for i_method = 1:settings.est.n_methods
%     
%     thisMethod = settings.est.methods_name{i_method};
%     
%     eval(['results.compare.MSE(:,' num2str(i_method) ') = mean(results.MSE.' thisMethod ...
%         ' ./ results.MSE.' settings.est.benchmark_method ', 2);']);
%     
%     eval(['results.compare.BIAS2(:,' num2str(i_method) ') = mean(results.BIAS2.' thisMethod ...
%         ' ./ results.BIAS2.' settings.est.benchmark_method ', 2);']);
%     
%     eval(['results.compare.VCE(:,' num2str(i_method) ') = mean(results.VCE.' thisMethod ...
%         ' ./ results.VCE.' settings.est.benchmark_method ', 2);']);
%     
% end
% 
% clear i_method thisMethod

%% PLOT RESULTS

%----------------------------------------------------------------
% Plot IRFs for Checking
%----------------------------------------------------------------

for i_method = 1:settings.est.n_methods
    
    thisMethod = settings.est.methods_name{i_method};
    figure(i_method)
    plot(settings.est.IRF_select, DF_model.target_irf(:,settings.specifications.plot_indx),'Linewidth',5)
    hold on
    for i = 1:settings.simul.n_MC
        eval(['plot(settings.est.IRF_select, results.irf.' thisMethod '(:,i,settings.specifications.plot_indx))']);
        hold on
    end
    title(replace(thisMethod,'_',' '))
    hold off

end

clear i_method thisMethod i