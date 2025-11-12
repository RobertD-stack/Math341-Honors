function dydt = muscle_regeneration_model(t, y, params)
% MUSCLE_REGENERATION_MODEL - ODE system for skeletal muscle regeneration
%
% This function implements the mathematical model from:
% Stephenson et al. (2018) "A mathematical model of skeletal muscle regeneration"
% Mathematical Methods in the Applied Sciences
%
% The model describes the dynamics of:
%   y(1) = N - Necrotic tissue (damaged muscle)
%   y(2) = M1 - M1 macrophages (pro-inflammatory)
%   y(3) = M2 - M2 macrophages (anti-inflammatory)
%   y(4) = S - Satellite cells (quiescent/activated)
%   y(5) = P - Myoblasts (proliferating cells)
%   y(6) = D - Differentiated myocytes
%   y(7) = M - Mature muscle fibers
%   y(8) = TNF - Tumor necrosis factor (pro-inflammatory cytokine)
%   y(9) = TGF - Transforming growth factor (anti-inflammatory cytokine)
%
% Inputs:
%   t      - Time
%   y      - State vector
%   params - Structure containing model parameters
%
% Output:
%   dydt   - Derivatives of state variables

% Extract state variables
N = y(1);    % Necrotic tissue
M1 = y(2);   % M1 macrophages
M2 = y(3);   % M2 macrophages
S = y(4);    % Satellite cells
P = y(5);    % Myoblasts
D = y(6);    % Differentiated myocytes
M = y(7);    % Mature muscle
TNF = y(8);  % Pro-inflammatory cytokine
TGF = y(9);  % Anti-inflammatory cytokine

% Extract parameters
p = params;

% Initialize derivatives
dydt = zeros(9,1);

% 1. Necrotic tissue dynamics
% Removal by M1 and M2 macrophages
dydt(1) = -p.delta_N1 * M1 * N - p.delta_N2 * M2 * N;

% 2. M1 macrophages (pro-inflammatory)
% Recruitment by necrotic tissue and TNF, polarization to M2
M1_recruitment = p.alpha_M1 * N * TNF / (p.K_M1 + TNF);
M1_to_M2 = p.gamma_M1 * M1 * TGF / (p.K_switch + TGF);
dydt(2) = M1_recruitment - M1_to_M2 - p.delta_M1 * M1;

% 3. M2 macrophages (anti-inflammatory)
% Polarization from M1, recruitment by necrotic tissue
M2_recruitment = p.alpha_M2 * N;
dydt(3) = M1_to_M2 + M2_recruitment - p.delta_M2 * M2;

% 4. Satellite cells
% Activation by TNF, self-renewal, differentiation to myoblasts
S_activation = p.rho_S * S * TNF / (p.K_S + TNF);
S_renewal = p.beta_S * S_activation;
dydt(4) = S_renewal - S_activation + p.sigma_S * (p.S0 - S);

% 5. Myoblasts (proliferating cells)
% From activated satellite cells, proliferation, differentiation
P_from_S = (1 - p.beta_S) * S_activation;
P_proliferation = p.rho_P * P * (1 - P/p.P_max);
P_differentiation = p.gamma_P * P * TGF / (p.K_P + TGF);
dydt(5) = P_from_S + P_proliferation - P_differentiation - p.delta_P * P;

% 6. Differentiated myocytes
% From myoblast differentiation, fusion into muscle fibers
D_from_P = P_differentiation;
D_fusion = p.gamma_D * D * M / (p.K_D + M);
dydt(6) = D_from_P - D_fusion - p.delta_D * D;

% 7. Mature muscle fibers
% Formation from differentiated myocytes, growth toward homeostasis
M_formation = p.lambda_M * D_fusion;
M_growth = p.mu_M * M * (p.M0 - M) / p.M0;
M_damage = p.delta_M * M * N / (p.K_damage + N);
dydt(7) = M_formation + M_growth - M_damage;

% 8. TNF (pro-inflammatory cytokine)
% Production by M1 macrophages and necrotic tissue
TNF_production = p.alpha_TNF * M1 * N / (p.K_TNF + N);
dydt(8) = TNF_production - p.delta_TNF * TNF;

% 9. TGF (anti-inflammatory cytokine)
% Production by M2 macrophages
TGF_production = p.alpha_TGF * M2;
dydt(9) = TGF_production - p.delta_TGF * TGF;

end





