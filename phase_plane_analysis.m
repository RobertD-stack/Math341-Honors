%% PHASE_PLANE_ANALYSIS
% Phase plane analysis of key variable interactions
% Explores dynamical behavior of the muscle regeneration system
%
% Based on Stephenson et al. (2018)

clear; close all; clc;

%% Setup
addpath(fileparts(which(mfilename)));
params = model_parameters();

%% Run baseline simulation
N0 = 20.0;
M1_0 = 0.5;
M2_0 = 0.1;
S0 = params.S0;
P0 = 0.5;
D0 = 0.0;
M0 = 0.3 * params.M0;
TNF0 = 0.5;
TGF0 = 0.1;
y0 = [N0; M1_0; M2_0; S0; P0; D0; M0; TNF0; TGF0];

tspan = [0 30];
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'NonNegative', 1:9);

fprintf('Running baseline simulation for phase plane analysis...\n');
[t, y] = ode45(@(t,y) muscle_regeneration_model(t, y, params), tspan, y0, options);

%% Extract variables
N = y(:,1);      % Necrotic tissue
M1 = y(:,2);     % M1 macrophages
M2 = y(:,3);     % M2 macrophages
S = y(:,4);      % Satellite cells
P = y(:,5);      % Myoblasts
D = y(:,6);      % Differentiated myocytes
M = y(:,7);      % Mature muscle
TNF = y(:,8);    % TNF cytokine
TGF = y(:,9);    % TGF cytokine

%% Create phase plane plots
figure('Position', [100 100 1400 900], 'Color', 'w');

% Define colors for trajectories
time_colors = jet(length(t));

% Plot 1: Muscle vs Necrotic Tissue
subplot(3,3,1)
for i = 1:length(t)-1
    plot([M(i) M(i+1)], [N(i) N(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(M(1), N(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(M(end), N(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(params.M0, 0, 'kx', 'MarkerSize', 15, 'LineWidth', 3);
xlabel('Muscle Mass (AU)', 'FontSize', 11);
ylabel('Necrotic Tissue (AU)', 'FontSize', 11);
title('Muscle vs Damage', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Equilibrium', 'Location', 'best');
grid on; box on;

% Plot 2: M1 vs M2 macrophages
subplot(3,3,2)
for i = 1:length(t)-1
    plot([M1(i) M1(i+1)], [M2(i) M2(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(M1(1), M2(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(M1(end), M2(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot([0 max(M1)], [0 max(M1)], 'k--', 'LineWidth', 1); % M1 = M2 line
xlabel('M1 Macrophages (AU)', 'FontSize', 11);
ylabel('M2 Macrophages (AU)', 'FontSize', 11);
title('Inflammatory Balance', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'M1=M2', 'Location', 'best');
grid on; box on;

% Plot 3: TNF vs TGF
subplot(3,3,3)
for i = 1:length(t)-1
    plot([TNF(i) TNF(i+1)], [TGF(i) TGF(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(TNF(1), TGF(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(TNF(end), TGF(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
xlabel('TNF (pro-inflam.) (AU)', 'FontSize', 11);
ylabel('TGF (anti-inflam.) (AU)', 'FontSize', 11);
title('Cytokine Balance', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Location', 'best');
grid on; box on;

% Plot 4: Satellite cells vs Myoblasts
subplot(3,3,4)
for i = 1:length(t)-1
    plot([S(i) S(i+1)], [P(i) P(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(S(1), P(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(S(end), P(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(params.S0, 0, 'kx', 'MarkerSize', 15, 'LineWidth', 3);
xlabel('Satellite Cells (AU)', 'FontSize', 11);
ylabel('Myoblasts (AU)', 'FontSize', 11);
title('Stem Cells vs Progenitors', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Equilibrium', 'Location', 'best');
grid on; box on;

% Plot 5: Myoblasts vs Differentiated cells
subplot(3,3,5)
for i = 1:length(t)-1
    plot([P(i) P(i+1)], [D(i) D(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(P(1), D(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(P(end), D(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
xlabel('Myoblasts (AU)', 'FontSize', 11);
ylabel('Differentiated Cells (AU)', 'FontSize', 11);
title('Proliferation vs Differentiation', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Location', 'best');
grid on; box on;

% Plot 6: Differentiated cells vs Muscle
subplot(3,3,6)
for i = 1:length(t)-1
    plot([D(i) D(i+1)], [M(i) M(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(D(1), M(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(D(end), M(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(0, params.M0, 'kx', 'MarkerSize', 15, 'LineWidth', 3);
xlabel('Differentiated Cells (AU)', 'FontSize', 11);
ylabel('Muscle Mass (AU)', 'FontSize', 11);
title('Fusion into Muscle', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Equilibrium', 'Location', 'best');
grid on; box on;

% Plot 7: Necrosis vs M1
subplot(3,3,7)
for i = 1:length(t)-1
    plot([N(i) N(i+1)], [M1(i) M1(i+1)], 'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot(N(1), M1(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(N(end), M1(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(0, 0, 'kx', 'MarkerSize', 15, 'LineWidth', 3);
xlabel('Necrotic Tissue (AU)', 'FontSize', 11);
ylabel('M1 Macrophages (AU)', 'FontSize', 11);
title('Damage vs Inflammation', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Equilibrium', 'Location', 'best');
grid on; box on;

% Plot 8: 3D phase space (M, N, P)
subplot(3,3,8)
for i = 1:length(t)-1
    plot3([M(i) M(i+1)], [N(i) N(i+1)], [P(i) P(i+1)], ...
          'Color', time_colors(i,:), 'LineWidth', 1.5);
    hold on;
end
plot3(M(1), N(1), P(1), 'go', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot3(M(end), N(end), P(end), 'ro', 'MarkerSize', 12, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot3(params.M0, 0, 0, 'kx', 'MarkerSize', 15, 'LineWidth', 3);
xlabel('Muscle (AU)', 'FontSize', 10);
ylabel('Necrosis (AU)', 'FontSize', 10);
zlabel('Myoblasts (AU)', 'FontSize', 10);
title('3D Phase Space', 'FontSize', 12, 'FontWeight', 'bold');
legend('', 'Start', 'End', 'Equilibrium', 'Location', 'best');
grid on; box on;
view(45, 30);

% Plot 9: Time evolution (colorbar reference)
subplot(3,3,9)
scatter(t, M, 50, t, 'filled');
colormap(jet);
cb = colorbar;
ylabel(cb, 'Time (days)', 'FontSize', 11);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Muscle Mass (AU)', 'FontSize', 11);
title('Time Color Reference', 'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;

sgtitle('Phase Plane Analysis of Muscle Regeneration Dynamics', ...
    'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, 'phase_plane_analysis.png');
fprintf('Phase plane figure saved.\n');

%% Vector field for M vs N
fprintf('Generating vector field for Muscle vs Necrosis...\n');

figure('Position', [100 100 1000 800], 'Color', 'w');

% Create grid
M_vec = linspace(0, 1.2*params.M0, 20);
N_vec = linspace(0, 30, 20);
[M_grid, N_grid] = meshgrid(M_vec, N_vec);

% Calculate derivatives at grid points
dM_grid = zeros(size(M_grid));
dN_grid = zeros(size(N_grid));

% Use baseline values for other variables (simplified analysis)
M1_base = mean(M1);
M2_base = mean(M2);
S_base = params.S0;
P_base = mean(P);
D_base = mean(D);
TNF_base = mean(TNF);
TGF_base = mean(TGF);

for i = 1:size(M_grid, 1)
    for j = 1:size(M_grid, 2)
        y_temp = [N_grid(i,j); M1_base; M2_base; S_base; P_base; ...
                  D_base; M_grid(i,j); TNF_base; TGF_base];
        dydt = muscle_regeneration_model(0, y_temp, params);
        dN_grid(i,j) = dydt(1);  % dN/dt
        dM_grid(i,j) = dydt(7);  % dM/dt
    end
end

% Plot vector field
quiver(M_grid, N_grid, dM_grid, dN_grid, 2, 'b', 'LineWidth', 1, 'AutoScale', 'on');
hold on;

% Overlay actual trajectory
plot(M, N, 'r-', 'LineWidth', 3);
plot(M(1), N(1), 'go', 'MarkerSize', 15, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(M(end), N(end), 'ro', 'MarkerSize', 15, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(params.M0, 0, 'kx', 'MarkerSize', 20, 'LineWidth', 4);

xlabel('Muscle Mass (AU)', 'FontSize', 13);
ylabel('Necrotic Tissue (AU)', 'FontSize', 13);
title('Vector Field: Muscle vs Necrosis Phase Plane', 'FontSize', 14, 'FontWeight', 'bold');
legend('Vector field', 'Trajectory', 'Initial', 'Final', 'Equilibrium', 'Location', 'best');
grid on; box on;
set(gca, 'FontSize', 12);

saveas(gcf, 'vector_field_M_vs_N.png');
fprintf('Vector field figure saved.\n');

%% Nullclines analysis (where derivatives = 0)
fprintf('Plotting nullclines...\n');

figure('Position', [100 100 1000 800], 'Color', 'w');

% For this simplified analysis, we look at dM/dt = 0 and dN/dt = 0

% Plot trajectory
plot(M, N, 'r-', 'LineWidth', 3); hold on;
plot(M(1), N(1), 'go', 'MarkerSize', 15, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot(M(end), N(end), 'ro', 'MarkerSize', 15, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot(params.M0, 0, 'kx', 'MarkerSize', 20, 'LineWidth', 4);

% Overlay contour where dM/dt ≈ 0
contour(M_grid, N_grid, dM_grid, [0 0], 'b-', 'LineWidth', 2, 'ShowText', 'on');

% Overlay contour where dN/dt ≈ 0
contour(M_grid, N_grid, dN_grid, [0 0], 'g-', 'LineWidth', 2, 'ShowText', 'on');

xlabel('Muscle Mass (AU)', 'FontSize', 13);
ylabel('Necrotic Tissue (AU)', 'FontSize', 13);
title('Nullcline Analysis: M-N Phase Plane', 'FontSize', 14, 'FontWeight', 'bold');
legend('Trajectory', 'Initial', 'Final', 'Equilibrium', ...
       'dM/dt=0', 'dN/dt=0', 'Location', 'best');
grid on; box on;
set(gca, 'FontSize', 12);

saveas(gcf, 'nullclines_M_vs_N.png');
fprintf('Nullcline figure saved.\n');

%% Time-parameterized 3D trajectory
figure('Position', [100 100 1000 800], 'Color', 'w');

% Plot 3D trajectory colored by time
for i = 1:length(t)-1
    plot3([M(i) M(i+1)], [P(i) P(i+1)], [D(i) D(i+1)], ...
          'Color', time_colors(i,:), 'LineWidth', 2);
    hold on;
end

plot3(M(1), P(1), D(1), 'go', 'MarkerSize', 15, 'LineWidth', 2, 'MarkerFaceColor', 'g');
plot3(M(end), P(end), D(end), 'ro', 'MarkerSize', 15, 'LineWidth', 2, 'MarkerFaceColor', 'r');
plot3(params.M0, 0, 0, 'kx', 'MarkerSize', 20, 'LineWidth', 4);

xlabel('Muscle Mass (AU)', 'FontSize', 12);
ylabel('Myoblasts (AU)', 'FontSize', 12);
zlabel('Differentiated Cells (AU)', 'FontSize', 12);
title('3D Trajectory: Muscle-Myoblast-Differentiated Space', ...
      'FontSize', 13, 'FontWeight', 'bold');
colormap(jet);
cb = colorbar;
ylabel(cb, 'Time (days)', 'FontSize', 11);
caxis([0 max(t)]);
grid on; box on;
view(45, 30);
legend('', 'Start', 'End', 'Equilibrium', 'Location', 'best');

saveas(gcf, 'trajectory_3D_MPD.png');
fprintf('3D trajectory figure saved.\n');

%% Summary
fprintf('\n========================================\n');
fprintf('PHASE PLANE ANALYSIS COMPLETE\n');
fprintf('========================================\n');
fprintf('Generated figures:\n');
fprintf('  1. phase_plane_analysis.png - Multiple 2D phase planes\n');
fprintf('  2. vector_field_M_vs_N.png - Vector field for M vs N\n');
fprintf('  3. nullclines_M_vs_N.png - Nullcline analysis\n');
fprintf('  4. trajectory_3D_MPD.png - 3D trajectory visualization\n');
fprintf('========================================\n');

%% Save workspace
save('phase_plane_results.mat', 't', 'y', 'params');
fprintf('Phase plane analysis data saved to phase_plane_results.mat\n');





