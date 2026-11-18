# Control system design

Control Engineering course labs (UTCN). The results and plots are explained in the [main README](../README.md#3-control-system-design).

| Script (`src/`) | Topic |
|---|---|
| `lab02_steady_state_error.m` | step and ramp steady-state error with P and PI controllers |
| `lab03_disturbance_rejection.m` | reference and disturbance paths, superposition, disturbance rejection |
| `lab04_step_and_frequency_response.m` | step, ramp and parabola responses; Bode plots |
| `lab05_controller_from_specs.m` | controller from overshoot / settling-time / bandwidth specifications |
| `lab06_direct_synthesis_dipole.m` | direct synthesis with a pole-zero dipole for the velocity constant |
| `lab07_p_pd_frequency_design.m` | P and PD controller design in the frequency domain |
| `lab08_pi_pid_frequency_design.m` | PI (lag) and PID controller design in the frequency domain |

`make_figures.m` regenerates the plots in `figures/` (MATLAB + Control System Toolbox).
