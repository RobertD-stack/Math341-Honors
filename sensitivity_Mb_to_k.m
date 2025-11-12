%% SENSITIVITY ANALYSIS: M_b with respect to k
% Calculate the sensitivity of Myoblast population (M_b) to the carrying
% capacity parameter k (P_max) using forward sensitivity equations
%
% Based on the Jacobian and sensitivity equations from:
% Stephenson et al. (2018)
%
% Creates a 3D visualization showing M_b, k, and time

clear; close all; clc;

fprintf('===========================================\n');
fprintf('Sensitivity Analysis: M_b to k (P_max)\n');
fprintf('===========================================\n\n');

%% Setup
addpath(fileparts(which(mfilename)));
params_base = model_parameters();

%% Initial Conditions
N0 = 20.0;              % Necrotic tissue (injury)
M1_0 = 0.5;             % M1 macrophages
M2_0 = 0.1;             % M2 macrophages
S0 = params_base.S0;    % Satellite cells
P0 = 0.5;               % Myoblasts (M_b)
D0 = 0.0;               % Differentiated myocytes
M0 = 0.3 * params_base.M0;  % Mature muscle (30% of healthy)
TNF0 = 0.5;             % TNF cytokine
TGF0 = 0.1;             % TGF cytokine

% State vector: [N, M1, M2, S, P, D, M, TNF, TGF]
y0 = [N0; M1_0; M2_0; S0; P0; D0; M0; TNF0; TGF0];

% Initial sensitivity (dP/dk at t=0) = 0
% We have 9 state variables, so 9 sensitivity equations
S0_sens = zeros(9, 1);

% Combined initial conditions: [state variables; sensitivities]
y0_combined = [y0; S0_sens];

%% Time span
tspan = [0 30];  % 30 days
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-9, 'NonNegative', 1:9);

%% Range of k values (P_max) to test
k_values = linspace(50, 200, 8);  % Test 8 different values of k
n_k = length(k_values);

%% Preallocate storage
t_all = cell(n_k, 1);
Mb_all = cell(n_k, 1);
sensitivity_all = cell(n_k, 1);

fprintf('Running sensitivity analysis for %d values of k...\n', n_k);

%% Solve for each k value
for i = 1:n_k
    k = k_values(i);
    
    % Modify parameters
    params_mod = params_base;
    params_mod.P_max = k;  % k is the myoblast carrying capacity
    
    fprintf('  k = %.1f... ', k);
    
    % Solve the combined ODE system (model + sensitivity equations)
    try
        [t, y_combined] = ode45(@(t,y) sensitivity_ode_system(t, y, params_mod), ...
                                tspan, y0_combined, options);
        
        % Extract results
        t_all{i} = t;
        Mb_all{i} = y_combined(:, 5);  % Myoblasts (P) is state variable 5
        sensitivity_all{i} = y_combined(:, 14);  % Sensitivity dP/dk is position 9+5=14
        
        fprintf('Done.\n');
    catch ME
        fprintf('Failed: %s\n', ME.message);
        t_all{i} = tspan;
        Mb_all{i} = NaN(2, 1);
        sensitivity_all{i} = NaN(2, 1);
    end
end

fprintf('\nSimulations complete.\n\n');

%% Create 3D Visualization
fprintf('Creating 3D visualization...\n');

figure('Position', [100 100 1400 900], 'Color', 'w');

% Subplot 1: 3D surface plot of M_b vs k vs time
subplot(2,2,[1 2])
hold on;

% Create mesh data for surface plot
max_length = max(cellfun(@length, t_all));
T_grid = linspace(0, 30, max_length);
K_grid = k_values;
Mb_grid = NaN(length(K_grid), length(T_grid));

% Interpolate all trajectories to common time grid
for i = 1:n_k
    if ~isnan(Mb_all{i}(1))
        Mb_grid(i, :) = interp1(t_all{i}, Mb_all{i}, T_grid, 'pchip', NaN);
    end
end

% Create 3D surface
[K_mesh, T_mesh] = meshgrid(K_grid, T_grid);
surf(T_mesh, K_mesh, Mb_grid', 'FaceAlpha', 0.8, 'EdgeColor', 'none');

% Overlay trajectories
colors = jet(n_k);
for i = 1:n_k
    if ~isnan(Mb_all{i}(1))
        plot3(t_all{i}, k_values(i)*ones(size(t_all{i})), Mb_all{i}, ...
              'Color', colors(i,:), 'LineWidth', 2.5);
    end
end

xlabel('Time (days)', 'FontSize', 13, 'FontWeight', 'bold');
ylabel('k (P_{max}) - Myoblast Carrying Capacity', 'FontSize', 13, 'FontWeight', 'bold');
zlabel('M_b - Myoblast Population (AU)', 'FontSize', 13, 'FontWeight', 'bold');
title('3D Visualization: M_b vs k vs Time', 'FontSize', 15, 'FontWeight', 'bold');
colormap(jet);
colorbar('Label', 'M_b (AU)');
grid on; box on;
view(45, 30);
set(gca, 'FontSize', 11);
hold off;

% Subplot 2: M_b trajectories over time for different k
subplot(2,2,3)
hold on;
for i = 1:n_k
    if ~isnan(Mb_all{i}(1))
        plot(t_all{i}, Mb_all{i}, 'LineWidth', 2.5, 'Color', colors(i,:), ...
             'DisplayName', sprintf('k=%.0f', k_values(i)));
    end
end
xlabel('Time (days)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('M_b - Myoblast Population (AU)', 'FontSize', 12, 'FontWeight', 'bold');
title('M_b Dynamics for Different k Values', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on; box on;
set(gca, 'FontSize', 10);
hold off;

% Subplot 3: Sensitivity dM_b/dk over time
subplot(2,2,4)
hold on;
for i = 1:n_k
    if ~isnan(sensitivity_all{i}(1))
        plot(t_all{i}, sensitivity_all{i}, 'LineWidth', 2.5, 'Color', colors(i,:), ...
             'DisplayName', sprintf('k=%.0f', k_values(i)));
    end
end
xlabel('Time (days)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Sensitivity dM_b/dk (AU per unit k)', 'FontSize', 12, 'FontWeight', 'bold');
title('Sensitivity of M_b to k Over Time', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on; box on;
set(gca, 'FontSize', 10);
hold off;

sgtitle('Sensitivity Analysis: Myoblast Population to Carrying Capacity', ...
        'FontSize', 16, 'FontWeight', 'bold');

saveas(gcf, 'Mb_sensitivity_3D.png');
fprintf('Figure saved as: Mb_sensitivity_3D.png\n');

%% Additional Analysis: Peak M_b vs k
figure('Position', [100 100 1200 500], 'Color', 'w');

% Calculate peak M_b and time to peak for each k
peak_Mb = zeros(n_k, 1);
time_to_peak = zeros(n_k, 1);
final_Mb = zeros(n_k, 1);

for i = 1:n_k
    if ~isnan(Mb_all{i}(1))
        [peak_Mb(i), idx_peak] = max(Mb_all{i});
        time_to_peak(i) = t_all{i}(idx_peak);
        final_Mb(i) = Mb_all{i}(end);
    end
end

subplot(1,3,1)
plot(k_values, peak_Mb, 'o-', 'LineWidth', 2.5, 'MarkerSize', 10, ...
     'MarkerFaceColor', [0.2 0.4 0.8]);
xlabel('k (P_{max})', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Peak M_b (AU)', 'FontSize', 12, 'FontWeight', 'bold');
title('Peak Myoblast Population', 'FontSize', 13, 'FontWeight', 'bold');
grid on; box on;
set(gca, 'FontSize', 11);

subplot(1,3,2)
plot(k_values, time_to_peak, 's-', 'LineWidth', 2.5, 'MarkerSize', 10, ...
     'MarkerFaceColor', [0.8 0.3 0.2]);
xlabel('k (P_{max})', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Time to Peak (days)', 'FontSize', 12, 'FontWeight', 'bold');
title('Time to Peak M_b', 'FontSize', 13, 'FontWeight', 'bold');
grid on; box on;
set(gca, 'FontSize', 11);

subplot(1,3,3)
plot(k_values, final_Mb, 'd-', 'LineWidth', 2.5, 'MarkerSize', 10, ...
     'MarkerFaceColor', [0.2 0.7 0.4]);
xlabel('k (P_{max})', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Final M_b (day 30) (AU)', 'FontSize', 12, 'FontWeight', 'bold');
title('Final Myoblast Population', 'FontSize', 13, 'FontWeight', 'bold');
grid on; box on;
set(gca, 'FontSize', 11);

sgtitle('M_b Response Metrics vs k', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'Mb_metrics_vs_k.png');
fprintf('Figure saved as: Mb_metrics_vs_k.png\n');

%% Print Summary
fprintf('\n===========================================\n');
fprintf('SENSITIVITY ANALYSIS SUMMARY\n');
fprintf('===========================================\n\n');
fprintf('Parameter: k (P_max) - Myoblast carrying capacity\n');
fprintf('State variable: M_b (P) - Myoblast population\n\n');

fprintf('Results for different k values:\n');
fprintf('%-10s | %-12s | %-15s | %-12s\n', 'k', 'Peak M_b', 'Time to Peak', 'Final M_b');
fprintf('--------------------------------------------------------------\n');
for i = 1:n_k
    fprintf('%-10.1f | %-12.2f | %-15.2f | %-12.2f\n', ...
            k_values(i), peak_Mb(i), time_to_peak(i), final_Mb(i));
end
fprintf('===========================================\n\n');

%% Save results
save('Mb_sensitivity_results.mat', 't_all', 'Mb_all', 'sensitivity_all', ...
     'k_values', 'peak_Mb', 'time_to_peak', 'final_Mb');
fprintf('Results saved to: Mb_sensitivity_results.mat\n');
fprintf('Analysis complete!\n\n');

