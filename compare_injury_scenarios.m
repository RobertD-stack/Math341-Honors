%% COMPARE_INJURY_SCENARIOS
% Compare muscle regeneration dynamics for different injury severities
% Based on Stephenson et al. (2018)
%
% This script simulates three scenarios:
%   1. Mild injury (10% muscle loss)
%   2. Moderate injury (30% muscle loss)
%   3. Severe injury (50% muscle loss)

clear; close all; clc;

%% Setup
addpath(fileparts(which(mfilename)));
params = model_parameters();

%% Define injury scenarios
scenarios = {
    'Mild (10% loss)',    0.90, 10.0;   % 90% muscle remaining, 10 AU necrosis
    'Moderate (30% loss)', 0.70, 20.0;  % 70% muscle remaining, 20 AU necrosis
    'Severe (50% loss)',   0.50, 35.0   % 50% muscle remaining, 35 AU necrosis
};

n_scenarios = size(scenarios, 1);
tspan = [0 40];  % Extended time for severe injuries
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'NonNegative', 1:9);

% Storage for results
results = cell(n_scenarios, 1);

%% Run simulations
fprintf('Comparing injury scenarios...\n');

for s = 1:n_scenarios
    fprintf('  Simulating %s...\n', scenarios{s,1});
    
    % Set initial conditions based on injury severity
    muscle_fraction = scenarios{s,2};
    necrosis_level = scenarios{s,3};
    
    N0 = necrosis_level;
    M1_0 = 0.3 + 0.1*necrosis_level;  % More M1 with worse injury
    M2_0 = 0.1;
    S0 = params.S0;
    P0 = 0.5;
    D0 = 0.0;
    M0 = muscle_fraction * params.M0;
    TNF0 = 0.3 + 0.02*necrosis_level;  % Higher TNF with worse injury
    TGF0 = 0.1;
    
    y0 = [N0; M1_0; M2_0; S0; P0; D0; M0; TNF0; TGF0];
    
    % Solve ODE
    [t, y] = ode45(@(t,y) muscle_regeneration_model(t, y, params), tspan, y0, options);
    
    % Store results
    results{s} = struct('t', t, 'y', y, 'name', scenarios{s,1}, ...
                        'muscle_frac', muscle_fraction, 'necrosis', necrosis_level);
end

fprintf('All scenarios complete.\n');

%% Create comparison visualization
figure('Position', [100 100 1400 1000], 'Color', 'w');

% Define colors for scenarios
colors = [0.2 0.8 0.4;   % Green for mild
          0.2 0.5 0.9;   % Blue for moderate
          0.9 0.3 0.2];  % Red for severe

% Plot 1: Muscle mass recovery
subplot(3,3,1)
hold on;
for s = 1:n_scenarios
    M = results{s}.y(:,7);
    plot(results{s}.t, M, 'LineWidth', 2.5, 'Color', colors(s,:));
end
yline(params.M0, 'k--', 'LineWidth', 1.5, 'Label', 'Homeostasis');
xlabel('Time (days)', 'FontSize', 11);
ylabel('Muscle Mass (AU)', 'FontSize', 11);
title('Muscle Mass Recovery', 'FontSize', 12, 'FontWeight', 'bold');
legend([scenarios(:,1); 'Homeostasis'], 'Location', 'southeast');
grid on; box on;

% Plot 2: Necrotic tissue clearance
subplot(3,3,2)
hold on;
for s = 1:n_scenarios
    N = results{s}.y(:,1);
    plot(results{s}.t, N, 'LineWidth', 2.5, 'Color', colors(s,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('Necrotic Tissue (AU)', 'FontSize', 11);
title('Necrotic Tissue Clearance', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'northeast');
grid on; box on;

% Plot 3: M1 macrophages
subplot(3,3,3)
hold on;
for s = 1:n_scenarios
    M1 = results{s}.y(:,2);
    plot(results{s}.t, M1, 'LineWidth', 2.5, 'Color', colors(s,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('M1 Macrophages (AU)', 'FontSize', 11);
title('Pro-inflammatory Response', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'northeast');
grid on; box on;

% Plot 4: M2 macrophages
subplot(3,3,4)
hold on;
for s = 1:n_scenarios
    M2 = results{s}.y(:,3);
    plot(results{s}.t, M2, 'LineWidth', 2.5, 'Color', colors(s,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('M2 Macrophages (AU)', 'FontSize', 11);
title('Anti-inflammatory Response', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'northeast');
grid on; box on;

% Plot 5: Satellite cells
subplot(3,3,5)
hold on;
for s = 1:n_scenarios
    S = results{s}.y(:,4);
    plot(results{s}.t, S, 'LineWidth', 2.5, 'Color', colors(s,:));
end
yline(params.S0, 'k--', 'LineWidth', 1.5);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Satellite Cells (AU)', 'FontSize', 11);
title('Satellite Cell Dynamics', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'best');
grid on; box on;

% Plot 6: Myoblasts
subplot(3,3,6)
hold on;
for s = 1:n_scenarios
    P = results{s}.y(:,5);
    plot(results{s}.t, P, 'LineWidth', 2.5, 'Color', colors(s,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('Myoblasts (AU)', 'FontSize', 11);
title('Myoblast Proliferation', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'northeast');
grid on; box on;

% Plot 7: TNF (pro-inflammatory cytokine)
subplot(3,3,7)
hold on;
for s = 1:n_scenarios
    TNF = results{s}.y(:,8);
    plot(results{s}.t, TNF, 'LineWidth', 2.5, 'Color', colors(s,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('TNF Level (AU)', 'FontSize', 11);
title('Pro-inflammatory Cytokine', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'northeast');
grid on; box on;

% Plot 8: TGF (anti-inflammatory cytokine)
subplot(3,3,8)
hold on;
for s = 1:n_scenarios
    TGF = results{s}.y(:,9);
    plot(results{s}.t, TGF, 'LineWidth', 2.5, 'Color', colors(s,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('TGF Level (AU)', 'FontSize', 11);
title('Anti-inflammatory Cytokine', 'FontSize', 12, 'FontWeight', 'bold');
legend(scenarios(:,1), 'Location', 'northeast');
grid on; box on;

% Plot 9: Recovery percentage over time
subplot(3,3,9)
hold on;
for s = 1:n_scenarios
    M = results{s}.y(:,7);
    recovery_pct = (M / params.M0) * 100;
    plot(results{s}.t, recovery_pct, 'LineWidth', 2.5, 'Color', colors(s,:));
end
yline(100, 'k--', 'LineWidth', 1.5);
yline(90, 'k:', 'LineWidth', 1);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Recovery (%)', 'FontSize', 11);
title('Percent Recovery', 'FontSize', 12, 'FontWeight', 'bold');
legend([scenarios(:,1); {'100%', '90%'}], 'Location', 'southeast');
grid on; box on;
ylim([0 110]);

sgtitle('Comparison of Injury Severity Scenarios (Stephenson et al. 2018)', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% Save figure
saveas(gcf, 'injury_scenarios_comparison.png');
fprintf('Figure saved as injury_scenarios_comparison.png\n');

%% Calculate and display metrics
fprintf('\n========================================\n');
fprintf('INJURY SCENARIO COMPARISON\n');
fprintf('========================================\n');

for s = 1:n_scenarios
    fprintf('\n%s:\n', scenarios{s,1});
    fprintf('  Initial conditions:\n');
    fprintf('    Muscle mass: %.2f AU (%.0f%% of normal)\n', ...
            results{s}.y(1,7), results{s}.muscle_frac*100);
    fprintf('    Necrotic tissue: %.2f AU\n', results{s}.necrosis);
    
    M = results{s}.y(:,7);
    N = results{s}.y(:,1);
    M1 = results{s}.y(:,2);
    t = results{s}.t;
    
    % Recovery metrics
    idx_90 = find(M >= 0.9*params.M0, 1);
    idx_95 = find(M >= 0.95*params.M0, 1);
    
    fprintf('  Regeneration outcomes:\n');
    fprintf('    Time to 90%% recovery: ');
    if ~isempty(idx_90)
        fprintf('%.2f days\n', t(idx_90));
    else
        fprintf('Not achieved\n');
    end
    
    fprintf('    Time to 95%% recovery: ');
    if ~isempty(idx_95)
        fprintf('%.2f days\n', t(idx_95));
    else
        fprintf('Not achieved\n');
    end
    
    fprintf('    Final muscle mass: %.2f AU (%.1f%% of normal)\n', ...
            M(end), 100*M(end)/params.M0);
    fprintf('    Peak M1 response: %.2f AU at day %.2f\n', ...
            max(M1), t(M1==max(M1)));
    fprintf('    Necrosis clearance (95%%): ');
    idx_clear = find(N < 0.05*max(N), 1);
    if ~isempty(idx_clear)
        fprintf('%.2f days\n', t(idx_clear));
    else
        fprintf('Not achieved\n');
    end
end

fprintf('\n========================================\n');

%% Create recovery time comparison bar chart
figure('Position', [100 100 800 500], 'Color', 'w');

recovery_times = zeros(n_scenarios, 2);
for s = 1:n_scenarios
    M = results{s}.y(:,7);
    t = results{s}.t;
    
    idx_90 = find(M >= 0.9*params.M0, 1);
    idx_95 = find(M >= 0.95*params.M0, 1);
    
    recovery_times(s,1) = isempty(idx_90) ? NaN : t(idx_90);
    recovery_times(s,2) = isempty(idx_95) ? NaN : t(idx_95);
end

bar(recovery_times);
set(gca, 'XTickLabel', scenarios(:,1));
ylabel('Recovery Time (days)', 'FontSize', 12);
xlabel('Injury Severity', 'FontSize', 12);
title('Recovery Time Comparison', 'FontSize', 13, 'FontWeight', 'bold');
legend('90% Recovery', '95% Recovery', 'Location', 'northwest');
grid on; box on;

saveas(gcf, 'recovery_time_comparison.png');

%% Save results
save('injury_comparison_results.mat', 'results', 'scenarios', 'params');
fprintf('\nResults saved to injury_comparison_results.mat\n');
fprintf('Figures saved: injury_scenarios_comparison.png, recovery_time_comparison.png\n');





