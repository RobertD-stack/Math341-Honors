%% SIMULATE_MUSCLE_REGENERATION
% Main simulation script for skeletal muscle regeneration model
% Based on Stephenson et al. (2018)
%
% This script:
%   1. Sets up initial conditions for muscle injury
%   2. Solves the ODE system
%   3. Visualizes the regeneration dynamics
%   4. Saves results

clear; close all; clc;

%% Add script directory to path (if functions are in same folder)
addpath(fileparts(which(mfilename)));

%% Load model parameters
params = model_parameters();

%% Initial Conditions
% Simulate an acute muscle injury at t=0
% All values in arbitrary units (AU)

% Initial damage
N0 = 20.0;          % Necrotic tissue (injury)
M1_0 = 0.5;         % Initial M1 macrophages
M2_0 = 0.1;         % Initial M2 macrophages
S0 = params.S0;     % Satellite cells at homeostasis
P0 = 0.5;           % Few myoblasts initially
D0 = 0.0;           % No differentiated cells initially
M0 = 0.3 * params.M0;  % Reduced muscle mass due to injury (30% of normal)
TNF0 = 0.5;         % Initial pro-inflammatory signal
TGF0 = 0.1;         % Low anti-inflammatory signal initially

y0 = [N0; M1_0; M2_0; S0; P0; D0; M0; TNF0; TGF0];

%% Time span
tspan = [0 30];  % Simulate for 30 days post-injury

%% Solve ODE system
fprintf('Solving muscle regeneration model...\n');
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'NonNegative', 1:9);
[t, y] = ode45(@(t,y) muscle_regeneration_model(t, y, params), tspan, y0, options);
fprintf('Simulation complete.\n');

%% Extract solutions
N = y(:,1);      % Necrotic tissue
M1 = y(:,2);     % M1 macrophages
M2 = y(:,3);     % M2 macrophages
S = y(:,4);      % Satellite cells
P = y(:,5);      % Myoblasts
D = y(:,6);      % Differentiated myocytes
M = y(:,7);      % Mature muscle
TNF = y(:,8);    % TNF cytokine
TGF = y(:,9);    % TGF cytokine

%% Create comprehensive visualization
figure('Position', [100 100 1400 900], 'Color', 'w');

% Plot 1: Necrotic tissue and macrophages
subplot(3,3,1)
plot(t, N, 'k-', 'LineWidth', 2); hold on;
plot(t, M1, 'r-', 'LineWidth', 2);
plot(t, M2, 'b-', 'LineWidth', 2);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Cell Population (AU)', 'FontSize', 11);
title('Necrotic Tissue & Macrophages', 'FontSize', 12, 'FontWeight', 'bold');
legend('Necrotic tissue', 'M1 (pro-inflam.)', 'M2 (anti-inflam.)', 'Location', 'best');
grid on; box on;

% Plot 2: Satellite cells
subplot(3,3,2)
plot(t, S, 'g-', 'LineWidth', 2); hold on;
yline(params.S0, 'g--', 'LineWidth', 1.5, 'Label', 'Homeostasis');
xlabel('Time (days)', 'FontSize', 11);
ylabel('Satellite Cells (AU)', 'FontSize', 11);
title('Satellite Cell Pool', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;

% Plot 3: Myoblasts and differentiated cells
subplot(3,3,3)
plot(t, P, 'm-', 'LineWidth', 2); hold on;
plot(t, D, 'c-', 'LineWidth', 2);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Cell Population (AU)', 'FontSize', 11);
title('Myoblasts & Differentiated Cells', 'FontSize', 12, 'FontWeight', 'bold');
legend('Myoblasts (P)', 'Differentiated (D)', 'Location', 'best');
grid on; box on;

% Plot 4: Muscle mass recovery
subplot(3,3,4)
plot(t, M, 'LineWidth', 2.5, 'Color', [0.8 0.4 0]); hold on;
yline(params.M0, '--', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5], 'Label', 'Homeostasis');
xlabel('Time (days)', 'FontSize', 11);
ylabel('Muscle Mass (AU)', 'FontSize', 11);
title('Muscle Mass Recovery', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
% Calculate percent recovery
percent_recovery = (M ./ params.M0) * 100;
text(0.6*max(t), 0.5*max(M), sprintf('Final: %.1f%%', percent_recovery(end)), ...
    'FontSize', 10, 'FontWeight', 'bold');

% Plot 5: Cytokines (inflammatory signals)
subplot(3,3,5)
plot(t, TNF, 'r-', 'LineWidth', 2); hold on;
plot(t, TGF, 'b-', 'LineWidth', 2);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Cytokine Level (AU)', 'FontSize', 11);
title('Inflammatory Signals', 'FontSize', 12, 'FontWeight', 'bold');
legend('TNF (pro-inflam.)', 'TGF (anti-inflam.)', 'Location', 'best');
grid on; box on;

% Plot 6: M1/M2 ratio (inflammatory balance)
subplot(3,3,6)
M1_M2_ratio = M1 ./ (M2 + 1e-10);  % Avoid division by zero
plot(t, M1_M2_ratio, 'k-', 'LineWidth', 2);
xlabel('Time (days)', 'FontSize', 11);
ylabel('M1/M2 Ratio', 'FontSize', 11);
title('Inflammatory Balance', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
yline(1, '--', 'LineWidth', 1, 'Color', [0.5 0.5 0.5], 'Label', 'M1=M2');

% Plot 7: Muscle regeneration phases
subplot(3,3,7)
yyaxis left
area(t, N, 'FaceColor', [1 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'k'); 
ylabel('Necrotic Tissue (AU)', 'FontSize', 11);
yyaxis right
plot(t, M, 'LineWidth', 2.5, 'Color', [0.8 0.4 0]);
ylabel('Muscle Mass (AU)', 'FontSize', 11);
xlabel('Time (days)', 'FontSize', 11);
title('Degeneration vs. Regeneration', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;

% Plot 8: Total cell activity (proliferative phase indicator)
subplot(3,3,8)
total_activity = P + D + M1 + M2;
plot(t, total_activity, 'k-', 'LineWidth', 2);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Total Regenerative Activity (AU)', 'FontSize', 11);
title('Regenerative Activity', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;

% Plot 9: Phase space (M vs N)
subplot(3,3,9)
plot(N, M, 'LineWidth', 2); hold on;
plot(N(1), M(1), 'go', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(N(end), M(end), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'r');
xlabel('Necrotic Tissue (AU)', 'FontSize', 11);
ylabel('Muscle Mass (AU)', 'FontSize', 11);
title('Phase Space: Muscle vs. Damage', 'FontSize', 12, 'FontWeight', 'bold');
legend('Trajectory', 'Initial', 'Final', 'Location', 'best');
grid on; box on;

sgtitle('Skeletal Muscle Regeneration Dynamics (Stephenson et al. 2018)', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% Save figure
saveas(gcf, 'muscle_regeneration_results.png');
fprintf('Figure saved as muscle_regeneration_results.png\n');

%% Summary statistics
fprintf('\n========================================\n');
fprintf('MUSCLE REGENERATION SUMMARY\n');
fprintf('========================================\n');
fprintf('Initial muscle mass: %.2f AU (%.1f%% of normal)\n', M(1), 100*M(1)/params.M0);
fprintf('Final muscle mass: %.2f AU (%.1f%% of normal)\n', M(end), 100*M(end)/params.M0);
fprintf('Peak necrotic tissue: %.2f AU at day %.2f\n', max(N), t(N==max(N)));
fprintf('Necrotic clearance time: %.2f days (95%% cleared)\n', ...
    t(find(N < 0.05*max(N), 1)));
fprintf('Peak M1 macrophages: %.2f AU at day %.2f\n', max(M1), t(M1==max(M1)));
fprintf('Peak M2 macrophages: %.2f AU at day %.2f\n', max(M2), t(M2==max(M2)));
fprintf('Peak myoblasts: %.2f AU at day %.2f\n', max(P), t(P==max(P)));
fprintf('Time to 90%% recovery: ');
idx_90 = find(M >= 0.9*params.M0, 1);
if ~isempty(idx_90)
    fprintf('%.2f days\n', t(idx_90));
else
    fprintf('Not achieved within simulation time\n');
end
fprintf('========================================\n');

%% Save workspace
save('muscle_regeneration_results.mat', 't', 'y', 'params', 'y0');
fprintf('Results saved to muscle_regeneration_results.mat\n');





