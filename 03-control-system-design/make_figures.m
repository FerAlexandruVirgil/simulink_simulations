%% make_figures.m - regenerates the figures used in README.md
% Uses the same plants and controller design steps as the lab scripts in src/.
% Requires: MATLAB + Control System Toolbox. Run from this folder.
clear; close all;
here = fileparts(mfilename('fullpath'));
out  = fullfile(here, 'figures');
if ~exist(out, 'dir'), mkdir(out); end
c = lines(4);

%% Lab 2 - steady-state error: P controller on a type-1 plant vs PI on a type-0 plant
t  = 0:0.01:15;
H1 = feedback(series(tf(12, 1), tf(1, [1 1 0])), 1);          % P,  Hf = 1/(s(s+1))
H2 = feedback(series(tf([2 2], [1 0]), tf(5, [2 1])), 1);     % PI, Hf = 5/(2s+1)
f = figure('Color', 'w', 'Position', [100 100 1100 420]);
cases = {H1, 'P controller, H_f = 1/(s(s+1))'; H2, 'PI controller, H_f = 5/(2s+1)'};
for k = 1:2
    H = cases{k, 1};
    yp = step(H, t); yv = lsim(H, t, t);
    subplot(1, 2, k);
    plot(t, ones(size(t)), ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2); hold on;
    plot(t, yp, 'LineWidth', 1.5, 'Color', c(1,:));
    plot(t, t, '-.', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2);
    plot(t, yv, '--', 'LineWidth', 1.5, 'Color', c(2,:));
    grid on; xlabel('t [s]'); ylabel('y(t)'); ylim([0 4]); xlim([0 4]);
    title({cases{k, 2}, sprintf('e_{ss,step} = %.3f,  e_{ss,ramp} = %.3f', abs(1 - yp(end)), t(end) - yv(end))});
    legend({'step reference', 'step response', 'ramp reference', 'ramp response'}, 'Location', 'northwest');
end
exportgraphics(f, fullfile(out, 'lab02_steady_state_error.png'), 'Resolution', 150);

%% Lab 3 - disturbance rejection with a PI controller (superposition)
t   = 0:0.1:30;
Hf  = tf(5, [2 1]);  Hc = tf([2 2], [1 0]);
Hry = feedback(Hc*Hf, 1);                    % reference -> output
Hpy = feedback(1, Hc*Hf);                    % output disturbance -> output
p   = 0.2*(t < 10) + 0.3*((t >= 10) & (t < 20)) + 0.4*(t >= 20);
yr  = step(Hry, t); yp = lsim(Hpy, p, t);
f = figure('Color', 'w', 'Position', [100 100 900 420]);
plot(t, yr + yp, 'LineWidth', 1.5); hold on; stairs(t, p, 'LineWidth', 1.2);
yline(1, 'k:'); grid on; ylim([0 1.15]); xlabel('t [s]'); ylabel('amplitude');
legend({'output y = y_r + y_p', 'step disturbance p(t)', 'reference'}, 'Location', 'east');
title('PI loop rejects stepwise output disturbances (integral action)');
exportgraphics(f, fullfile(out, 'lab03_disturbance_rejection.png'), 'Resolution', 150);

%% Labs 7-8 - frequency-domain design of P, PD, PI (lag) and PID on Hf = 3.5/(s(0.5s+1))
Hf = tf(3.5, [0.5 1 0]);
C = struct();
% P (lab 7): gain from the magnitude condition for sigma = 7 %
s7 = 0.07; z7 = abs(log(s7)/sqrt(pi^2 + log(s7)^2));
A = 1/(4*sqrt(2)*z7^2); Vrp = db2mag(-(1.85 - db(A)));
C.P = tf(Vrp, 1);
% PD (lab 7): zero cancels the plant pole (Td = 0.5 s), pole moved tsp/tspd times further left.
% Note: src/lab07 uses Tn = Td*(tsp/tspd), which makes the block a lag; the lead form
% (Tn = Td*(tspd/tsp), same as the derivative part of the PID in src/lab08) is used here.
tsp = 3.88; tspd = 2; Td = 0.5; Tn = Td*(tspd/tsp);
C.PD = tf([Vrp*(tsp/tspd)*Td Vrp*(tsp/tspd)], [Tn 1]);
% PI / lag (lab 8): raise the velocity constant from 1.25 to 7
Vrp8 = 0.3423; cvp = 1.25; cvpi = 7; wt1 = 1.06;
wz = wt1/10; Tz = 1/wz; Tp = 1/(wz*(cvp/cvpi));
C.PI = tf([Vrp8*(cvpi/cvp)*Tz Vrp8*(cvpi/cvp)], [Tp 1]);
% PID (lab 8): lag + lead
tspid = 0.7; Tn2 = Td*(tspid/tsp);
Vrpid = Vrp8*(cvpi/cvp)*(tsp/tspid);
C.PID = series(tf([Vrpid*Tz Vrpid], [Tp 1]), tf([Td 1], [Tn2 1]));

names = fieldnames(C); t = 0:0.005:12;
f = figure('Color', 'w', 'Position', [100 100 1100 440]);
subplot(1, 2, 1); hold on;
fprintf('\n%-4s %10s %10s %10s %10s\n', 'Hc', 'sigma[%]', 'ts[s]', 'cv[1/s]', 'PM[deg]');
leg = cell(size(names));
for k = 1:numel(names)
    L  = series(C.(names{k}), Hf); H = feedback(L, 1);
    y  = step(H, t); si = stepinfo(H);
    tr = 0:0.01:50; e = tr(end) - lsim(H, tr, tr); e = e(end);
    [~, pm] = margin(L);
    fprintf('%-4s %10.2f %10.2f %10.2f %10.1f\n', names{k}, si.Overshoot, si.SettlingTime, 1/e, pm);
    plot(t, y, 'LineWidth', 1.5);
    leg{k} = sprintf('%s: \\sigma = %.1f %%, t_s = %.2f s, c_v = %.2f', names{k}, si.Overshoot, si.SettlingTime, 1/e);
end
yline(1, 'k:'); grid on; box on; xlabel('t [s]'); ylabel('y(t)');
legend(leg, 'Location', 'southeast'); title('Closed-loop step responses, H_f = 3.5 / (s(0.5s+1))');
subplot(1, 2, 2);
opts = bodeoptions; opts.PhaseVisible = 'off'; opts.Grid = 'on'; opts.Title.String = 'Open-loop magnitude L(j\omega)';
bodeplot(series(C.P, Hf), series(C.PD, Hf), series(C.PI, Hf), series(C.PID, Hf), {1e-3, 1e2}, opts);
legend(names, 'Location', 'southwest');
exportgraphics(f, fullfile(out, 'lab07_08_p_pd_pi_pid.png'), 'Resolution', 150);
