%% SENSITIVITY_ANALYSIS
% Perform sensitivity analysis on muscle regeneration model
% This script analyzes how changes in key parameters affect regeneration outcomes
%
% Based on Stephenson et al. (2018)

clear; close all; clc;

%% Setup
addpath(fileparts(which(mfilename)));
params_base = model_parameters();

%% Initial Conditions (same as main simulation)
N0 = 20.0;
M1_0 = 0.5;
M2_0 = 0.1;
S0 = params_base.S0;
P0 = 0.5;
D0 = 0.0;
M0 = 0.3 * params_base.M0;
TNF0 = 0.5;
TGF0 = 0.1;
y0 = [N0; M1_0; M2_0; S0; P0; D0; M0; TNF0; TGF0];

tspan = [0 30];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'NonNegative', 1:9);

%% Select parameters for sensitivity analysis
param_names = {
    'rho_P',        'Myoblast proliferation rate';
    'gamma_P',      'Myoblast differentiation rate';
    'delta_N1',     'Necrotic removal by M1';
    'alpha_M1',     'M1 recruitment rate';
    'gamma_M1',     'M1 to M2 polarization rate';
    'lambda_M',     'Fusion efficiency';
    'mu_M',         'Muscle growth rate';
    'sigma_S',      'Satellite cell replenishment'
};

n_params = size(param_names, 1);
variation_factors = [0.5, 0.75, 1.0, 1.25, 1.5];  % Vary ±50%
n_variations = length(variation_factors);

%% Preallocate results
recovery_time = zeros(n_params, n_variations);
final_muscle = zeros(n_params, n_variations);
peak_necrosis = zeros(n_params, n_variations);

%% Run sensitivity analysis
fprintf('Running sensitivity analysis...\n');
fprintf('Testing %d parameters with %d variations each\n', n_params, n_variations);

for i = 1:n_params
    param_name = param_names{i,1};
    fprintf('  Analyzing %s...\n', param_name);
    
    for j = 1:n_variations
        % Create modified parameters
        params_mod = params_base;
        params_mod.(param_name) = params_base.(param_name) * variation_factors(j);
        
        % Solve ODE
        try
            [t, y] = ode45(@(t,y) muscle_regeneration_model(t, y, params_mod), ...
                           tspan, y0, options);
            
            % Extract metrics
            M = y(:,7);  % Muscle mass
            N = y(:,1);  % Necrotic tissue
            
            % Time to 90% recovery
            idx_90 = find(M >= 0.9*params_base.M0, 1);
            if ~isempty(idx_90)
                recovery_time(i,j) = t(idx_90);
            else
                recovery_time(i,j) = NaN;
            end
            
            % Final muscle mass
            final_muscle(i,j) = M(end);
            
            % Peak necrosis
            peak_necrosis(i,j) = max(N);
            
        catch ME
            fprintf('    Warning: Simulation failed for %s at %.2fx\n', ...
                    param_name, variation_factors(j));
            recovery_time(i,j) = NaN;
            final_muscle(i,j) = NaN;
            peak_necrosis(i,j) = NaN;
        end
    end
end

fprintf('Sensitivity analysis complete.\n');

%% Visualize Results

% Figure 1: Recovery Time Sensitivity
figure('Position', [100 100 1400 500], 'Color', 'w');

subplot(1,3,1)
imagesc(variation_factors, 1:n_params, recovery_time);
colorbar;
colormap(jet);
set(gca, 'YTick', 1:n_params, 'YTickLabel', param_names(:,2));
xlabel('Parameter Variation Factor', 'FontSize', 11);
title('Time to 90% Recovery (days)', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 10);

subplot(1,3,2)
imagesc(variation_factors, 1:n_params, final_muscle);
colorbar;
colormap(jet);
set(gca, 'YTick', 1:n_params, 'YTickLabel', param_names(:,2));
xlabel('Parameter Variation Factor', 'FontSize', 11);
title('Final Muscle Mass (AU)', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 10);

subplot(1,3,3)
imagesc(variation_factors, 1:n_params, peak_necrosis);
colorbar;
colormap(jet);
set(gca, 'YTick', 1:n_params, 'YTickLabel', param_names(:,2));
xlabel('Parameter Variation Factor', 'FontSize', 11);
title('Peak Necrotic Tissue (AU)', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, 'FontSize', 10);

sgtitle('Parameter Sensitivity Analysis', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_heatmaps.png');

% Figure 2: Individual parameter effects
figure('Position', [100 100 1400 900], 'Color', 'w');

for i = 1:n_params
    subplot(3, 3, i);
    
    % Plot recovery time vs parameter variation
    yyaxis left
    plot(variation_factors, recovery_time(i,:), 'o-', 'LineWidth', 2, 'MarkerSize', 8);
    ylabel('Recovery Time (days)', 'FontSize', 10);
    
    yyaxis right
    plot(variation_factors, final_muscle(i,:), 's-', 'LineWidth', 2, 'MarkerSize', 8);
    ylabel('Final Muscle (AU)', 'FontSize', 10);
    
    xlabel('Variation Factor', 'FontSize', 10);
    title(param_names{i,2}, 'FontSize', 11, 'FontWeight', 'bold');
    grid on; box on;
    xline(1.0, '--', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5]);
end

sgtitle('Parameter Effects on Regeneration Outcomes', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_curves.png');

%% Calculate sensitivity indices (normalized)
% Sensitivity = (change in output) / (change in parameter)

baseline_recovery = recovery_time(:, variation_factors == 1.0);
baseline_muscle = final_muscle(:, variation_factors == 1.0);

% Calculate relative sensitivity for ±25% variation
idx_low = find(variation_factors == 0.75);
idx_high = find(variation_factors == 1.25);

sens_recovery = zeros(n_params, 1);
sens_muscle = zeros(n_params, 1);

for i = 1:n_params
    % Relative change in output / relative change in parameter
    if ~isnan(recovery_time(i,idx_low)) && ~isnan(recovery_time(i,idx_high))
        delta_recovery = (recovery_time(i,idx_high) - recovery_time(i,idx_low)) / baseline_recovery(i);
        delta_param = (1.25 - 0.75) / 1.0;
        sens_recovery(i) = delta_recovery / delta_param;
    else
        sens_recovery(i) = NaN;
    end
    
    if ~isnan(final_muscle(i,idx_low)) && ~isnan(final_muscle(i,idx_high))
        delta_muscle = (final_muscle(i,idx_high) - final_muscle(i,idx_low)) / baseline_muscle(i);
        sens_muscle(i) = delta_muscle / delta_param;
    else
        sens_muscle(i) = NaN;
    end
end

% Figure 3: Sensitivity ranking
figure('Position', [100 100 1200 500], 'Color', 'w');

subplot(1,2,1)
barh(1:n_params, sens_recovery, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'YTick', 1:n_params, 'YTickLabel', param_names(:,2));
xlabel('Normalized Sensitivity', 'FontSize', 11);
title('Sensitivity: Recovery Time', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
xline(0, 'k-', 'LineWidth', 1.5);

subplot(1,2,2)
barh(1:n_params, sens_muscle, 'FaceColor', [0.8 0.4 0.2]);
set(gca, 'YTick', 1:n_params, 'YTickLabel', param_names(:,2));
xlabel('Normalized Sensitivity', 'FontSize', 11);
title('Sensitivity: Final Muscle Mass', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
xline(0, 'k-', 'LineWidth', 1.5);

sgtitle('Sensitivity Rankings (±25% Parameter Variation)', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'sensitivity_rankings.png');

%% Print summary
fprintf('\n========================================\n');
fprintf('SENSITIVITY ANALYSIS SUMMARY\n');
fprintf('========================================\n');
fprintf('\nMost sensitive parameters for RECOVERY TIME:\n');
[~, idx_sort] = sort(abs(sens_recovery), 'descend');
for i = 1:min(3, n_params)
    if ~isnan(sens_recovery(idx_sort(i)))
        fprintf('  %d. %s: %.3f\n', i, param_names{idx_sort(i),2}, sens_recovery(idx_sort(i)));
    end
end

fprintf('\nMost sensitive parameters for FINAL MUSCLE MASS:\n');
[~, idx_sort] = sort(abs(sens_muscle), 'descend');
for i = 1:min(3, n_params)
    if ~isnan(sens_muscle(idx_sort(i)))
        fprintf('  %d. %s: %.3f\n', i, param_names{idx_sort(i),2}, sens_muscle(idx_sort(i)));
    end
end
fprintf('========================================\n');

%% Save results
save('sensitivity_results.mat', 'recovery_time', 'final_muscle', 'peak_necrosis', ...
     'sens_recovery', 'sens_muscle', 'param_names', 'variation_factors');
fprintf('\nResults saved to sensitivity_results.mat\n');
fprintf('Figures saved: sensitivity_heatmaps.png, sensitivity_curves.png, sensitivity_rankings.png\n');





