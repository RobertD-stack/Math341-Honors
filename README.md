# Skeletal Muscle Regeneration Model - MATLAB Implementation

This repository contains MATLAB scripts implementing the mathematical model of skeletal muscle regeneration described in:

**Stephenson et al. (2018). "A mathematical model of skeletal muscle regeneration." Mathematical Methods in the Applied Sciences.**

## Overview

The model describes the complex biological process of muscle regeneration following injury through a system of 9 ordinary differential equations (ODEs) that track:

- **Necrotic tissue** (damaged muscle)
- **Immune cells**: M1 macrophages (pro-inflammatory) and M2 macrophages (anti-inflammatory)
- **Muscle progenitor cells**: Satellite cells, myoblasts, and differentiated myocytes
- **Mature muscle fibers**
- **Cytokines**: TNF (pro-inflammatory) and TGF-β (anti-inflammatory)

## Files Description

### Core Model Files

1. **`muscle_regeneration_model.m`**
   - Main ODE function defining the regeneration dynamics
   - Implements the complete 9-equation system
   - Inputs: time, state vector, parameters
   - Output: derivatives (dy/dt)

2. **`model_parameters.m`**
   - Defines all model parameters with physiologically meaningful values
   - Returns a structure containing all rate constants and saturation parameters
   - Includes homeostatic values for muscle mass and satellite cell pools

### Simulation Scripts

3. **`simulate_muscle_regeneration.m`**
   - **Main simulation script** - Run this first!
   - Sets up initial conditions for an acute muscle injury
   - Solves the ODE system using MATLAB's ode45 solver
   - Generates comprehensive 9-panel visualization showing:
     - Necrotic tissue clearance
     - Macrophage dynamics (M1 vs M2)
     - Satellite cell activation
     - Myoblast proliferation and differentiation
     - Muscle mass recovery
     - Cytokine profiles
     - Inflammatory balance (M1/M2 ratio)
     - Phase space analysis
   - Saves results as `.mat` file and figure as `.png`

4. **`sensitivity_analysis.m`**
   - Performs comprehensive parameter sensitivity analysis
   - Tests 8 key parameters at 5 different variation levels (±50%)
   - Analyzes effects on:
     - Recovery time (time to 90% muscle mass restoration)
     - Final muscle mass
     - Peak necrotic tissue
   - Generates three figures:
     - Heatmaps showing parameter sensitivities
     - Individual parameter effect curves
     - Sensitivity rankings (bar charts)
   - Calculates normalized sensitivity indices

5. **`compare_injury_scenarios.m`**
   - Compares regeneration outcomes for different injury severities
   - Simulates three scenarios:
     - Mild injury (10% muscle loss)
     - Moderate injury (30% muscle loss)
     - Severe injury (50% muscle loss)
   - Generates comparative visualization

## Getting Started

### Prerequisites

- MATLAB R2016b or later
- No additional toolboxes required (uses base MATLAB functions)

### Quick Start

1. **Basic simulation** (recommended first step):
   ```matlab
   simulate_muscle_regeneration
   ```
   This will:
   - Run a 30-day simulation of muscle regeneration
   - Display a comprehensive 9-panel figure
   - Print summary statistics to console
   - Save results to `muscle_regeneration_results.mat` and `muscle_regeneration_results.png`

2. **Sensitivity analysis**:
   ```matlab
   sensitivity_analysis
   ```
   This will:
   - Test how parameter variations affect outcomes
   - Generate 3 figures showing sensitivities
   - Save results to `sensitivity_results.mat`

3. **Compare injury scenarios**:
   ```matlab
   compare_injury_scenarios
   ```
   This will:
   - Simulate mild, moderate, and severe injuries
   - Generate comparative plots
   - Save results to `injury_comparison_results.mat`

## Model Structure

### State Variables

| Variable | Description | Units |
|----------|-------------|-------|
| N | Necrotic tissue (damaged muscle) | AU |
| M1 | M1 macrophages (pro-inflammatory) | AU |
| M2 | M2 macrophages (anti-inflammatory) | AU |
| S | Satellite cells | AU |
| P | Myoblasts (proliferating cells) | AU |
| D | Differentiated myocytes | AU |
| M | Mature muscle fibers | AU |
| TNF | Tumor necrosis factor | AU |
| TGF | Transforming growth factor β | AU |

*AU = Arbitrary Units*

### Key Biological Processes Modeled

1. **Inflammatory Phase**
   - Necrotic tissue triggers M1 macrophage recruitment via TNF
   - M1 macrophages clear debris and produce pro-inflammatory signals
   - M1 polarizes to M2 phenotype in response to TGF-β

2. **Proliferative Phase**
   - Satellite cells activate in response to TNF
   - Activated satellite cells differentiate into myoblasts
   - Myoblasts proliferate with density-dependent growth
   - TGF-β promotes myoblast differentiation

3. **Remodeling Phase**
   - Differentiated myocytes fuse into muscle fibers
   - Muscle mass grows toward homeostatic level
   - M2 macrophages promote anti-inflammatory environment
   - System returns to equilibrium

### Parameter Groups

- **Removal/decay rates** (δ parameters): Cell death and clearance
- **Recruitment/production rates** (α parameters): Cell influx and cytokine production  
- **Differentiation/polarization rates** (γ parameters): Cell state transitions
- **Proliferation rates** (ρ parameters): Cell division
- **Saturation constants** (K parameters): Half-maximal response levels
- **Growth rates** (μ, λ, σ parameters): Tissue growth and homeostasis

## Typical Results

For a moderate injury (30% muscle loss):

- **Necrotic clearance**: ~5-7 days (95% cleared)
- **Peak inflammation**: Days 1-3 (M1 dominant)
- **Peak proliferation**: Days 4-8 (myoblast expansion)
- **90% recovery**: ~15-20 days
- **Full recovery**: ~25-30 days

## Customization

### Modifying Initial Conditions

Edit the initial condition vector in `simulate_muscle_regeneration.m`:

```matlab
N0 = 20.0;          % Necrotic tissue (injury severity)
M0 = 0.3 * params.M0;  % Reduced muscle mass (30% loss)
```

### Modifying Parameters

Edit values in `model_parameters.m`:

```matlab
params.rho_P = 0.8;  % Myoblast proliferation rate
params.gamma_P = 0.5;  % Differentiation rate
```

### Extending Simulation Time

Modify the time span in simulation scripts:

```matlab
tspan = [0 60];  % Simulate for 60 days instead of 30
```

## Output Files

### Data Files (.mat)
- `muscle_regeneration_results.mat` - Main simulation time series
- `sensitivity_results.mat` - Sensitivity analysis data
- `injury_comparison_results.mat` - Multi-scenario comparison data

### Figures (.png)
- `muscle_regeneration_results.png` - 9-panel dynamics visualization
- `sensitivity_heatmaps.png` - Parameter sensitivity heatmaps
- `sensitivity_curves.png` - Individual parameter effects
- `sensitivity_rankings.png` - Sensitivity bar charts
- `injury_scenarios_comparison.png` - Multi-scenario comparison

## Biological Insights

The model captures key regeneration principles:

1. **Biphasic inflammatory response**: Early M1 dominance transitions to M2-mediated resolution
2. **Satellite cell homeostasis**: Pool maintains equilibrium through self-renewal
3. **Proliferation-differentiation balance**: Controlled by cytokine signals
4. **Coordinated repair**: Multiple cell types interact through cytokine networks
5. **Injury severity dependence**: More severe injuries require longer recovery

## Extensions and Future Work

Possible model extensions:

- Add fibrosis pathway (excessive collagen deposition)
- Include chronic injury scenarios
- Model aging effects (reduced satellite cell pool)
- Add exercise/loading effects on regeneration
- Incorporate angiogenesis (blood vessel formation)
- Model pharmacological interventions

## Troubleshooting

### Common Issues

1. **Negative values in solution**
   - Check that `NonNegative` option is set in odeset
   - Verify parameter values are positive

2. **Simulation is very slow**
   - Reduce RelTol and AbsTol (but may decrease accuracy)
   - Reduce time span if testing

3. **No convergence**
   - Some parameter combinations may be unstable
   - Check that parameters are in reasonable ranges

## References

1. Stephenson et al. (2018). "A mathematical model of skeletal muscle regeneration." *Mathematical Methods in the Applied Sciences*.

2. Related biological references:
   - Chazaud, B. (2016). "Inflammation and skeletal muscle regeneration." *Current Opinion in Rheumatology*.
   - Tidball, J.G. (2017). "Regulation of muscle growth and regeneration by the immune system." *Nature Reviews Immunology*.

## License

These scripts are provided for educational and research purposes.

## Author

MATLAB implementation based on the mathematical model by Stephenson et al. (2018).

## Contact

For questions about the model or implementation, please refer to the original publication.

---

**Last Updated**: November 2025





