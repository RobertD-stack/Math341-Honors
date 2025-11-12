function dydt_combined = sensitivity_ode_system(t, y_combined, params)
% SENSITIVITY_ODE_SYSTEM - Combined ODE system for state variables and sensitivities
%
% This function implements:
%   1. Original muscle regeneration model (9 state variables)
%   2. Forward sensitivity equations (9 sensitivity variables dS_i/dk)
%
% The sensitivity parameter is k = P_max (myoblast carrying capacity)
%
% Inputs:
%   t           - Time
%   y_combined  - Combined state vector [state vars (9); sensitivities (9)]
%   params      - Model parameters
%
% Output:
%   dydt_combined - Derivatives [dydt (9); dSdt (9)]

% Extract state variables (first 9 components)
y = y_combined(1:9);
N = y(1);    % Necrotic tissue
M1 = y(2);   % M1 macrophages
M2 = y(3);   % M2 macrophages
S = y(4);    % Satellite cells
P = y(5);    % Myoblasts (M_b)
D = y(6);    % Differentiated myocytes
M = y(7);    % Mature muscle
TNF = y(8);  % Pro-inflammatory cytokine
TGF = y(9);  % Anti-inflammatory cytokine

% Extract sensitivity variables (last 9 components)
% Sens_i = dS_i/dk where k = P_max
Sens = y_combined(10:18);

% Get parameter k (P_max)
k = params.P_max;

%% 1. Calculate original model derivatives
dydt = muscle_regeneration_model(t, y, params);

%% 2. Calculate Jacobian matrix J (9x9)
% The Jacobian J_ij = df_i/dy_j
J = calculate_jacobian(y, params);

%% 3. Calculate partial derivatives of f with respect to k (P_max)
% df_i/dk for each equation i
df_dk = zeros(9, 1);

% Most equations don't directly depend on k = P_max
% Only equation 5 (myoblasts) depends on k through the logistic term

% Equation 5: dP/dt = ... + rho_P * P * (1 - P/P_max) - ...
% df_5/dk = df_5/dP_max = rho_P * P * (P / P_max^2)
df_dk(5) = params.rho_P * P * (P / (k^2));

%% 4. Calculate sensitivity derivatives using forward sensitivity equations
% dS_i'/dt = J * S + df/dk
% where S is the sensitivity vector [dN/dk, dM1/dk, ..., dTGF/dk]

dSens_dt = J * Sens + df_dk;

%% 5. Combine derivatives
dydt_combined = [dydt; dSens_dt];

end


function J = calculate_jacobian(y, params)
% CALCULATE_JACOBIAN - Compute the Jacobian matrix of the model
%
% J(i,j) = df_i/dy_j where f is the RHS of the ODE system
%
% State variables: y = [N, M1, M2, S, P, D, M, TNF, TGF]

% Extract state variables
N = y(1);
M1 = y(2);
M2 = y(3);
S = y(4);
P = y(5);
D = y(6);
M = y(7);
TNF = y(8);
TGF = y(9);

% Extract parameters (shortened names for readability)
p = params;

% Initialize Jacobian
J = zeros(9, 9);

%% Row 1: dN/dt = -delta_N1*M1*N - delta_N2*M2*N
J(1,1) = -p.delta_N1*M1 - p.delta_N2*M2;           % dF1/dN
J(1,2) = -p.delta_N1*N;                             % dF1/dM1
J(1,3) = -p.delta_N2*N;                             % dF1/dM2

%% Row 2: dM1/dt = alpha_M1*N*TNF/(K_M1+TNF) - gamma_M1*M1*TGF/(K_switch+TGF) - delta_M1*M1
J(2,1) = p.alpha_M1*TNF/(p.K_M1+TNF);              % dF2/dN
J(2,2) = -p.gamma_M1*TGF/(p.K_switch+TGF) - p.delta_M1;  % dF2/dM1
J(2,8) = p.alpha_M1*N*p.K_M1/((p.K_M1+TNF)^2);     % dF2/dTNF
J(2,9) = -p.gamma_M1*M1*p.K_switch/((p.K_switch+TGF)^2);  % dF2/dTGF

%% Row 3: dM2/dt = gamma_M1*M1*TGF/(K_switch+TGF) + alpha_M2*N - delta_M2*M2
J(3,1) = p.alpha_M2;                                % dF3/dN
J(3,2) = p.gamma_M1*TGF/(p.K_switch+TGF);         % dF3/dM1
J(3,3) = -p.delta_M2;                               % dF3/dM2
J(3,9) = p.gamma_M1*M1*p.K_switch/((p.K_switch+TGF)^2);  % dF3/dTGF

%% Row 4: dS/dt = beta_S*rho_S*S*TNF/(K_S+TNF) - rho_S*S*TNF/(K_S+TNF) + sigma_S*(S0-S)
% Simplifies to: -rho_S*S*TNF*(1-beta_S)/(K_S+TNF) + sigma_S*(S0-S)
J(4,4) = -p.rho_S*TNF*(1-p.beta_S)/(p.K_S+TNF) - p.sigma_S;  % dF4/dS
J(4,8) = -p.rho_S*S*(1-p.beta_S)*p.K_S/((p.K_S+TNF)^2);      % dF4/dTNF

%% Row 5: dP/dt = (1-beta_S)*rho_S*S*TNF/(K_S+TNF) + rho_P*P*(1-P/P_max) - gamma_P*P*TGF/(K_P+TGF) - delta_P*P
J(5,4) = (1-p.beta_S)*p.rho_S*TNF/(p.K_S+TNF);     % dF5/dS
J(5,5) = p.rho_P*(1-2*P/p.P_max) - p.gamma_P*TGF/(p.K_P+TGF) - p.delta_P;  % dF5/dP
J(5,8) = (1-p.beta_S)*p.rho_S*S*p.K_S/((p.K_S+TNF)^2);  % dF5/dTNF
J(5,9) = -p.gamma_P*P*p.K_P/((p.K_P+TGF)^2);       % dF5/dTGF

%% Row 6: dD/dt = gamma_P*P*TGF/(K_P+TGF) - gamma_D*D*M/(K_D+M) - delta_D*D
J(6,5) = p.gamma_P*TGF/(p.K_P+TGF);                % dF6/dP
J(6,6) = -p.gamma_D*M/(p.K_D+M) - p.delta_D;       % dF6/dD
J(6,7) = -p.gamma_D*D*p.K_D/((p.K_D+M)^2);         % dF6/dM
J(6,9) = p.gamma_P*P*p.K_P/((p.K_P+TGF)^2);        % dF6/dTGF

%% Row 7: dM/dt = lambda_M*gamma_D*D*M/(K_D+M) + mu_M*M*(M0-M)/M0 - delta_M*M*N/(K_damage+N)
J(7,1) = -p.delta_M*M*p.K_damage/((p.K_damage+N)^2);  % dF7/dN
J(7,6) = p.lambda_M*p.gamma_D*M/(p.K_D+M);         % dF7/dD
J(7,7) = p.lambda_M*p.gamma_D*D*p.K_D/((p.K_D+M)^2) + ...
         p.mu_M*(p.M0-2*M)/p.M0 - p.delta_M*N/(p.K_damage+N);  % dF7/dM

%% Row 8: dTNF/dt = alpha_TNF*M1*N/(K_TNF+N) - delta_TNF*TNF
J(8,1) = p.alpha_TNF*M1*p.K_TNF/((p.K_TNF+N)^2);   % dF8/dN
J(8,2) = p.alpha_TNF*N/(p.K_TNF+N);                % dF8/dM1
J(8,8) = -p.delta_TNF;                              % dF8/dTNF

%% Row 9: dTGF/dt = alpha_TGF*M2 - delta_TGF*TGF
J(9,3) = p.alpha_TGF;                               % dF9/dM2
J(9,9) = -p.delta_TGF;                              % dF9/dTGF

end

