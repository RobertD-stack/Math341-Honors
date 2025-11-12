# Quick Start Guide - Muscle Regeneration Model

## Installation

No installation required! Just ensure you have MATLAB R2016b or later.

---

## 5-Minute Quick Start

### Step 1: Run Main Simulation

Open MATLAB and navigate to the project directory, then run:

```matlab
simulate_muscle_regeneration
```

**What it does:**
- Simulates 30 days of muscle regeneration after injury
- Generates a 9-panel figure showing all dynamics
- Prints summary statistics
- Saves results

**Expected output:**
- Console output with regeneration metrics
- Figure window with comprehensive visualizations
- Files created: `muscle_regeneration_results.mat`, `muscle_regeneration_results.png`

**Typical results:**
- Time to 90% recovery: ~15-20 days
- Final muscle mass: ~95-100% of normal
- Necrotic clearance: ~5-7 days

---

### Step 2: Compare Different Injuries (Optional)

```matlab
compare_injury_scenarios
```

**What it does:**
- Compares mild (10%), moderate (30%), and severe (50%) muscle loss
- Shows how injury severity affects recovery timeline
- Generates comparative plots

**Expected output:**
- 9-panel comparison figure
- Bar chart of recovery times
- Files created: `injury_comparison_results.mat`, `injury_scenarios_comparison.png`

---

### Step 3: Parameter Sensitivity (Optional)

```matlab
sensitivity_analysis
```

**What it does:**
- Tests how parameter variations affect outcomes
- Identifies most influential parameters
- Generates heatmaps and rankings

**Expected output:**
- 3 figures showing sensitivities
- Console output ranking parameter importance
- Files created: `sensitivity_results.mat`, multiple PNG files

**Note:** This takes longer (~2-3 minutes) as it runs many simulations

---

## Understanding the Results

### Key Metrics to Look For

1. **Muscle Mass Recovery**
   - Should increase from ~30% to ~100% of normal
   - Nonlinear: slow start, rapid middle phase, slow finish
   - Target: 90% recovery in 15-20 days

2. **Necrotic Tissue**
   - Should decrease rapidly from injury level to near zero
   - Most clearance happens in first week
   - Indicates successful debris removal

3. **M1/M2 Balance**
   - M1 (red line) peaks early (days 1-3)
   - M2 (blue line) peaks later (days 5-10)
   - Shift from M1 to M2 indicates resolution of inflammation

4. **Myoblast Expansion**
   - Should peak around days 5-10
   - Then decline as cells differentiate
   - Indicates active regeneration phase

---

## Common Modifications

### Change Injury Severity

Edit in `simulate_muscle_regeneration.m`:

```matlab
% Mild injury
N0 = 10.0;           % Less necrotic tissue
M0 = 0.7 * params.M0; % 70% muscle remaining

% Severe injury
N0 = 35.0;           % More necrotic tissue
M0 = 0.5 * params.M0; % Only 50% muscle remaining
```

### Extend Simulation Time

```matlab
tspan = [0 60];  % Simulate 60 days instead of 30
```

### Modify Parameters

Edit in `model_parameters.m`, for example:

```matlab
% Faster proliferation
params.rho_P = 1.2;  % Increase from 0.8

% Reduced satellite cell pool (aging effect)
params.S0 = 5.0;     % Decrease from 10.0

% Enhanced fusion efficiency
params.lambda_M = 0.9;  % Increase from 0.7
```

---

## Interpreting the Main Figure

The 9-panel figure from `simulate_muscle_regeneration` shows:

### Row 1: Cellular Populations
1. **Necrotic Tissue & Macrophages** - Damage clearance
2. **Satellite Cell Pool** - Stem cell dynamics
3. **Myoblasts & Differentiated Cells** - Progenitor expansion

### Row 2: Key Metrics
4. **Muscle Mass Recovery** - Main outcome measure
5. **Inflammatory Signals (TNF/TGF)** - Cytokine balance
6. **M1/M2 Ratio** - Inflammatory resolution

### Row 3: Integrative Views
7. **Degeneration vs Regeneration** - Dual axis plot
8. **Total Regenerative Activity** - Overall cellular activity
9. **Phase Space** - Trajectory from injury to recovery

---

## Troubleshooting

### Problem: Figure doesn't appear
**Solution:** Check that MATLAB is not in "batch mode". Run `figure` first.

### Problem: "Function not found" error
**Solution:** Make sure you're in the correct directory:
```matlab
cd('C:\Users\super\Documents\Coding Projects\Park Analysis')
```

### Problem: Simulation is slow
**Solution:** This is normal for sensitivity analysis. For faster testing:
```matlab
tspan = [0 15];  % Shorter time
```

### Problem: Strange results (negative values, divergence)
**Solution:** 
- Check that parameters are positive
- Verify initial conditions are reasonable
- The NonNegative option should prevent this, but extreme parameters may cause issues

---

## Next Steps

### For Research Use

1. **Modify parameters** to match experimental data
2. **Add your own measurements** as comparison data
3. **Test interventions** by changing specific rates
4. **Export data** for further analysis:
   ```matlab
   load('muscle_regeneration_results.mat')
   writematrix([t, y], 'results.csv')
   ```

### For Learning

1. Read `MODEL_SUMMARY.md` for mathematical details
2. Explore `phase_plane_analysis.m` for dynamical systems insights
3. Modify one parameter at a time to understand effects
4. Compare with biological literature

### For Presentation

1. All figures are saved as high-resolution PNGs
2. Use `print(gcf, 'figure_name', '-dpdf')` for PDF output
3. Data in `.mat` files can be loaded for custom plotting
4. Modify figure titles/labels in scripts as needed

---

## File Structure Summary

```
Park Analysis/
├── muscle_regeneration_model.m      [Core ODE system]
├── model_parameters.m               [Parameter values]
├── simulate_muscle_regeneration.m   [Main simulation - START HERE]
├── compare_injury_scenarios.m       [Multi-scenario comparison]
├── sensitivity_analysis.m           [Parameter sensitivity]
├── phase_plane_analysis.m          [Dynamical analysis]
├── README.md                        [Full documentation]
├── MODEL_SUMMARY.md                 [Mathematical details]
└── QUICK_START.md                   [This file]
```

---

## Command Summary

```matlab
% Basic workflow
simulate_muscle_regeneration     % Main simulation (always run this first)
compare_injury_scenarios         % Compare injury severities
sensitivity_analysis             % Parameter effects (takes ~2-3 min)
phase_plane_analysis            % Advanced: phase plane plots

% Utility commands
load('muscle_regeneration_results.mat')  % Load saved results
help muscle_regeneration_model           % View function documentation
edit model_parameters                    % Open parameter file
```

---

## Getting Help

1. **Function help:**
   ```matlab
   help muscle_regeneration_model
   help model_parameters
   ```

2. **Documentation:**
   - `README.md` - Comprehensive guide
   - `MODEL_SUMMARY.md` - Mathematical details
   - Comments in each `.m` file

3. **Common issues:** See Troubleshooting section above

---

## Citation

If you use this code for research, please cite:

**Stephenson et al. (2018). "A mathematical model of skeletal muscle regeneration." Mathematical Methods in the Applied Sciences.**

---

**Happy modeling! 🔬💪**

*Last updated: November 2025*





