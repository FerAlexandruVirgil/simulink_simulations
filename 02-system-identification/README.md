# System identification

System Identification course labs and project (UTCN). The results and plots are explained in the [main README](../README.md#2-system-identification).

| Folder | Script | Data | Topic |
|---|---|---|---|
| `lab2-polynomial-regression` | `polynomial_regression.m` | `lab2_13.mat` | least-squares polynomial fit, model-order selection |
| `lab3-first-order-dc-motor` | `first_order_identification.m` | `step_dateDCM.mat`, `impuls_dateDCM.mat` | first-order model of a DC motor from step / impulse tests |
| `lab4-correlation-fir` | `correlation_fir_identification.m` | `lab4_dateDCM.mat` | correlation analysis, FIR impulse-response estimation |
| `project-2d-polynomial-fit` | `polynomial_fit_2d.m` | `proj_fit_01.mat` | 2-input polynomial approximator, identification and validation |

`make_figures.m` regenerates every plot in `figures/` from the stored data, without any hardware.
The original lab scripts record data from the motor through the lab's `DCMRun` toolbox, which is not included. Skip those sections and load the `.mat` files instead.
