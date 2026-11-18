%% make_figures.m - regenerates the figures used in README.md from the recorded data
% Only uses the .mat files in the lab/project folders (no DC motor hardware needed).
% Requires: base MATLAB + Control System Toolbox (tf, lsim). Run from this folder.
clear; close all;
here = fileparts(mfilename('fullpath'));
out  = fullfile(here, 'figures');
if ~exist(out, 'dir'), mkdir(out); end
c = lines(3);

%% Lab 2 - polynomial regression (least squares), model order selection on validation data
d = load(fullfile(here, 'lab2-polynomial-regression', 'lab2_13.mat'));
id = d.id; val = d.val;
degs = 0:20; mse_id = zeros(size(degs)); mse_val = mse_id;
for k = 1:numel(degs)
    th = vander_(id.X, degs(k)) \ id.Y(:);
    mse_id(k)  = mean((vander_(id.X, degs(k))*th  - id.Y(:)).^2);
    mse_val(k) = mean((vander_(val.X, degs(k))*th - val.Y(:)).^2);
end
[~, kb] = min(mse_val); nb = degs(kb);
th = vander_(id.X, nb) \ id.Y(:);
f = figure('Color', 'w', 'Position', [100 100 1100 420]);
subplot(1, 2, 1);
plot(val.X, val.Y, '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 10); hold on;
plot(id.X, id.Y, 'o', 'Color', c(1,:), 'MarkerSize', 4);
xs = linspace(min(val.X), max(val.X), 400);
plot(xs, vander_(xs, nb)*th, 'LineWidth', 1.8, 'Color', c(2,:));
grid on; xlabel('x'); ylabel('y'); legend({'validation data', 'identification data', sprintf('model, degree %d', nb)}, 'Location', 'northwest');
title(sprintf('Polynomial model (degree %d): MSE_{val} = %.2f', nb, mse_val(kb)));
subplot(1, 2, 2);
semilogy(degs, mse_id, '-o', degs, mse_val, '-o', 'LineWidth', 1.3); hold on;
plot(nb, mse_val(kb), 'p', 'MarkerSize', 14, 'MarkerFaceColor', 'g', 'Color', 'k');
grid on; xlabel('polynomial degree'); ylabel('MSE'); legend({'identification', 'validation', 'best on validation'});
title('Model order selection (overfitting appears on validation)');
exportgraphics(f, fullfile(out, 'lab2_polynomial_regression.png'), 'Resolution', 150);
fprintf('lab2: best degree = %d, MSE id = %.3f, MSE val = %.3f\n', nb, mse_id(kb), mse_val(kb));

%% Lab 3 - first-order model of a DC motor from step and impulse experiments
d = load(fullfile(here, 'lab3-first-order-dc-motor', 'step_dateDCM.mat'));
u = zeros(1, 370); u(31:100) = 0.7; u(171:270) = 0.4; u(301:370) = -0.5;   % input used in the experiment
Ts = median(diff(d.t)); t = (0:numel(d.t)-1)*Ts; y = d.vel;   % ~10 ms, resampled to an even grid for lsim
y_id = y(31:100); t_id = t(31:100) - t(31);
yss = mean(y_id(end-20:end)); K = yss/0.7;
T = t_id(find(y_id >= 0.632*yss, 1));
G = tf(K, [T 1]);
yv = lsim(G, u, t);
mse3 = mean((yv(171:370) - y(171:370)').^2);
f = figure('Color', 'w', 'Position', [100 100 1100 420]);
subplot(1, 2, 1);
plot(t, y, 'Color', c(1,:), 'LineWidth', 1.2); hold on; plot(t, yv, '--', 'Color', c(2,:), 'LineWidth', 1.5);
stairs(t, u*max(abs(y))/0.7, ':', 'Color', [0.4 0.4 0.4]);
xline(t(171), 'k--', 'validation', 'LabelVerticalAlignment', 'top');
grid on; xlabel('t [s]'); ylabel('speed');
legend({'measured', sprintf('G(s) = %.2f / (%.3fs + 1)', K, T), 'input (scaled)'}, 'Location', 'southwest');
title(sprintf('Step identification, MSE_{val} = %.4f', mse3));
fprintf('lab3 step: K = %.4f, T = %.4f s, MSE val = %.5f\n', K, T, mse3);

d = load(fullfile(here, 'lab3-first-order-dc-motor', 'impuls_dateDCM.mat'));
Ts = median(diff(d.t)); t = (0:numel(d.t)-1)'*Ts; y = d.vel(:); ui = d.u_imp(:);
yss = mean(y(100:130)); Ki = yss/0.1;            % steady state for the 0.1 base input, before the next pulse
dv = y - yss; [ymax, im] = max(dv);
i36 = find(dv(im:end) <= 0.368*ymax, 1) + im - 1; Ti = t(i36) - t(im);
Gi = tf(Ki, [Ti 1]);
Gs = ss(Gi); yi = lsim(Gs, ui(35:end), t(35:end) - t(35), Ki*0.1/Gs.C);   % start from the u = 0.1 steady state
subplot(1, 2, 2);
plot(t, y, 'Color', c(1,:), 'LineWidth', 1.2); hold on; plot(t(35:end), yi, '--', 'Color', c(2,:), 'LineWidth', 1.5);
grid on; xlabel('t [s]'); ylabel('speed');
legend({'measured', sprintf('G(s) = %.2f / (%.3fs + 1)', Ki, Ti)}, 'Location', 'northeast');
title(sprintf('Impulse identification, MSE = %.4f', mean((yi - y(35:end)).^2)));
exportgraphics(f, fullfile(out, 'lab3_first_order_dc_motor.png'), 'Resolution', 150);
fprintf('lab3 impulse: K = %.4f, T = %.4f s\n', Ki, Ti);

%% Lab 4 - nonparametric identification: correlation analysis -> FIR impulse response
d = load(fullfile(here, 'lab4-correlation-fir', 'lab4_dateDCM.mat'));
n = 30; Nid = 500; ts = 0.01;
u = d.u(:); y = d.y(:);
idx_id = n+1 : n+Nid; idx_val = n+Nid+1 : length(u);
ui = u(idx_id) - mean(u(idx_id)); yi = y(idx_id) - mean(y(idx_id));
N = numel(ui); ru = zeros(N, 1); ryu = zeros(N, 1);
for tau = 0:N-1
    k = 1:N-tau;
    ru(tau+1)  = sum(ui(k+tau).*ui(k))/N;
    ryu(tau+1) = sum(yi(k+tau).*ui(k))/N;
end
Ms = 5:5:150; mi = zeros(size(Ms)); mv = mi; H = cell(size(Ms));
for q = 1:numel(Ms)
    Phi = toeplitz(ru(1:N), ru(1:Ms(q)));       % Phi(i,j) = r_u(|i-j|)
    H{q} = Phi \ ryu;
    yh = conv(H{q}, u); yh = yh(1:numel(u));
    mi(q) = mean((y(idx_id) - yh(idx_id)).^2); mv(q) = mean((y(idx_val) - yh(idx_val)).^2);
end
q60 = find(Ms == 60); h = H{q60};
yh = conv(h, u); yh = yh(1:numel(u)); tt = (0:numel(u)-1)'*ts;
f = figure('Color', 'w', 'Position', [100 100 1150 420]);
subplot(1, 3, [1 2]);
plot(tt, y, 'Color', c(1,:)); hold on; plot(tt, yh, 'Color', c(2,:), 'LineWidth', 1.2);
xline(tt(idx_val(1)), 'k--', 'validation', 'LabelVerticalAlignment', 'bottom');
grid on; xlabel('t [s]'); ylabel('speed'); legend({'measured', 'FIR model (M = 60)'}, 'Location', 'southwest');
title(sprintf('Random-input experiment: MSE_{id} = %.4f, MSE_{val} = %.4f', mi(q60), mv(q60)));
subplot(1, 3, 3);
stem((0:numel(h)-1)*ts, h, 'filled', 'MarkerSize', 3); grid on; xlabel('lag [s]'); ylabel('h(k)');
title('Estimated impulse response (M = 60)');
exportgraphics(f, fullfile(out, 'lab4_correlation_fir.png'), 'Resolution', 150);
fprintf('lab4: M = 60 -> MSE id = %.5f, MSE val = %.5f\n', mi(q60), mv(q60));

%% Project - 2-input polynomial approximator of an unknown static nonlinearity
d = load(fullfile(here, 'project-2d-polynomial-fit', 'proj_fit_01.mat'));
id = d.id; val = d.val;
degs = 1:15; pm_id = zeros(size(degs)); pm_val = pm_id;
for k = 1:numel(degs)
    [Pid, Pval] = deal(regs_(id.X, degs(k)), regs_(val.X, degs(k)));
    th = Pid \ reshape(id.Y', [], 1);
    pm_id(k)  = mean((Pid*th  - reshape(id.Y', [], 1)).^2);
    pm_val(k) = mean((Pval*th - reshape(val.Y', [], 1)).^2);
end
nproj = 7;                                                % degree used in the project script
th = regs_(id.X, nproj) \ reshape(id.Y', [], 1);
Yv = reshape(regs_(val.X, nproj)*th, numel(val.X{1}), numel(val.X{2}))';
[X1, X2] = meshgrid(val.X{1}, val.X{2});
f = figure('Color', 'w', 'Position', [100 100 1200 420]);
subplot(1, 3, 1); surf(X1, X2, val.Y, 'EdgeColor', 'none'); title('Validation data'); xlabel('x_1'); ylabel('x_2'); view(-35, 30);
subplot(1, 3, 2); surf(X1, X2, Yv, 'EdgeColor', 'none'); title(sprintf('Polynomial model, degree %d', nproj)); xlabel('x_1'); ylabel('x_2'); view(-35, 30);
cl = [min([val.Y(:); Yv(:)]) max([val.Y(:); Yv(:)])]; subplot(1, 3, 1); clim(cl); subplot(1, 3, 2); clim(cl);
subplot(1, 3, 3);
semilogy(degs, pm_id, '-o', degs, pm_val, '-o', 'LineWidth', 1.3); hold on; xline(nproj, 'k:');
grid on; xlabel('total degree m'); ylabel('MSE'); legend({'identification', 'validation'}, 'Location', 'northeast');
title('MSE vs. polynomial degree');
exportgraphics(f, fullfile(out, 'project_2d_polynomial_fit.png'), 'Resolution', 150);
fprintf('project: degree %d -> MSE id = %.5f, MSE val = %.5f; best val degree = %d (MSE %.5f)\n', ...
    nproj, pm_id(nproj), pm_val(nproj), degs(find(pm_val == min(pm_val), 1)), min(pm_val));

%% helpers
function P = vander_(x, n)            % columns 1, x, ..., x^n
    P = x(:).^(0:n);
end

function P = regs_(X, n)              % all monomials x1^i * x2^j with i + j <= n, on the grid X{1} x X{2}
    [a, b] = meshgrid(X{1}, X{2});
    a = reshape(a', [], 1); b = reshape(b', [], 1);
    P = zeros(numel(a), (n+1)*(n+2)/2); p = 1;
    for i = 0:n
        for j = 0:(n-i)
            P(:, p) = a.^i .* b.^j; p = p + 1;
        end
    end
end
