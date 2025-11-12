function params = model_parameters()
% MODEL_PARAMETERS - Set parameters for muscle regeneration model
%
% This function defines all parameters for the skeletal muscle regeneration
% model based on Stephenson et al. (2018)
%
% Output:
%   params - Structure containing all model parameters
%
% Units: Time in days, cells in arbitrary units (AU)

params = struct();

%% Necrotic tissue parameters
params.delta_N1 = 0.8;      % Necrotic tissue removal rate by M1 (1/day)
params.delta_N2 = 0.6;      % Necrotic tissue removal rate by M2 (1/day)

%% M1 macrophage parameters
params.alpha_M1 = 0.5;      % M1 recruitment rate (1/day)
params.K_M1 = 1.0;          % Half-saturation for TNF-induced M1 recruitment (AU)
params.gamma_M1 = 0.3;      % M1 to M2 polarization rate (1/day)
params.K_switch = 2.0;      % Half-saturation for M1->M2 switch (AU)
params.delta_M1 = 0.4;      % M1 decay/death rate (1/day)

%% M2 macrophage parameters
params.alpha_M2 = 0.2;      % M2 recruitment rate (1/day)
params.delta_M2 = 0.3;      % M2 decay/death rate (1/day)

%% Satellite cell parameters
params.rho_S = 1.2;         % Satellite cell activation rate (1/day)
params.K_S = 0.5;           % Half-saturation for TNF-induced activation (AU)
params.beta_S = 0.4;        % Fraction of activated cells returning to quiescence
params.sigma_S = 0.1;       % Satellite cell pool replenishment rate (1/day)
params.S0 = 10.0;           % Homeostatic satellite cell level (AU)

%% Myoblast parameters
params.rho_P = 0.8;         % Myoblast proliferation rate (1/day)
params.P_max = 100.0;       % Maximum myoblast capacity (AU)
params.gamma_P = 0.5;       % Myoblast differentiation rate (1/day)
params.K_P = 1.5;           % Half-saturation for TGF-induced differentiation (AU)
params.delta_P = 0.2;       % Myoblast death rate (1/day)

%% Differentiated myocyte parameters
params.gamma_D = 0.6;       % Myocyte fusion rate (1/day)
params.K_D = 5.0;           % Half-saturation for muscle-mediated fusion (AU)
params.delta_D = 0.15;      % Myocyte death rate (1/day)

%% Mature muscle parameters
params.lambda_M = 0.7;      % Efficiency of myocyte fusion into muscle (dimensionless)
params.mu_M = 0.3;          % Muscle growth rate (1/day)
params.M0 = 50.0;           % Homeostatic muscle mass (AU)
params.delta_M = 0.1;       % Muscle damage rate (1/day)
params.K_damage = 10.0;     % Half-saturation for necrosis-induced damage (AU)

%% Cytokine parameters (TNF)
params.alpha_TNF = 2.0;     % TNF production rate (1/day)
params.K_TNF = 5.0;         % Half-saturation for TNF production (AU)
params.delta_TNF = 1.5;     % TNF decay rate (1/day)

%% Cytokine parameters (TGF)
params.alpha_TGF = 1.5;     % TGF production rate (1/day)
params.delta_TGF = 1.0;     % TGF decay rate (1/day)

%% Display parameters
fprintf('Model parameters loaded successfully.\n');
fprintf('Homeostatic values:\n');
fprintf('  Satellite cells (S0): %.1f AU\n', params.S0);
fprintf('  Muscle mass (M0): %.1f AU\n', params.M0);
fprintf('  Max myoblasts (P_max): %.1f AU\n', params.P_max);

end





