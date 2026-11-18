# Buck converter – design, Simscape model and voltage control

Power Electronics course project (UTCN). The results and plots are explained in the [main README](../README.md#1-buck-converter--design-simscape-model-and-closed-loop-voltage-control).

| Part | Script (`src/`) | Model(s) | Output |
|---|---|---|---|
| 1. Sizing, ideal simulation | `proiect.m`, `tema1_figuri.m` | `simulare1.slx` | `figures/t1_*.png` |
| 2. Simscape model with parasitics and tolerances | `tema2_simscape.m` | `tema2_model.slx` (built by the script) | `figures/t2_*.png`, `results/t2_rezultate.mat` |
| 3. State-space model and controller synthesis | `tema3.m`, `tema3_figuri.m` | `tema3_reglare.slx` (built by the script) | `figures/t3_*.png`, `results/t3_rezultate.mat` |
| 3.B Controller validation on the Simscape model | `tema3b.m` | `tema3b_simscape.slx`, `tema3b_fara_regulator.slx` (built by the script) | `figures/t3b_*.png`, `results/t3b_rezultate.mat` |

Reusable subsystems used by the Simscape models: `generator_pwm.slx`, `transistor_driver.slx`, `current_senzor.slx`, `voltage_sensor.slx`.

**Labs with a hysteresis modulator:**

| File | Content |
|---|---|
| `lab3-hysteresis-modulator/lab3_buck_closed_loop.slx` | hysteresis modulator driving a buck converter written as state equations, in a closed loop with a 14 V reference |
| `lab3-hysteresis-modulator/lab3_simulate.m` | simulates the closed loop and writes `figures/lab3_buck_hysteresis.png` |
| `ep2-hysteresis-modulator/ep2_modulator.slx` | the modulator on its own: integrator + relay with hysteresis, 0/1 output (input left unconnected in the model) |
| `ep2-hysteresis-modulator/ep2_simulate.m` | simulates the model as saved, then with a stepped command added in memory; writes `figures/ep2_hysteresis_modulator.png` |

Neither script saves changes to the `.slx` files.

Run any script from `src/` (MATLAB R2026a, Simulink, Simscape Electrical, Control System Toolbox). Comments and plot labels are in Romanian, and so are the reports in `reports/`.
