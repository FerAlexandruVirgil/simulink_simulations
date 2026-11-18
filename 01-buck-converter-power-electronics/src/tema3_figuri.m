%% Tema 3 - construieste tema3_reglare.slx, simuleaza si salveaza figurile
% Ruleaza tema3.m (proces Hp si regulator Hc), construieste schema
%   Uout -> (+/-) -> Hc -> ZOH (1/freq) -> saturatie (0->1) -> Hp -> reactie
% simuleaza bucla si salveaza figurile t3_*.png si rezultatele in ../results/t3_rezultate.mat.
clear; close all;
cd(fileparts(mfilename('fullpath')));
tema3;
fprintf('A = [%s; %s]\nB = [%g; %g]\n', num2str(A(1,:), '%.6g  '), num2str(A(2,:), '%.6g  '), B(1), B(2));
fprintf('Hc(s) factorizat: K = %.6g, zerouri: s^2 + %.6g s + %.6g, poli: %s\n', num_c(1), num_c(2)/num_c(1), num_c(3)/num_c(1), mat2str(roots(den_c)', 6));
banda = 0.02*u_out;

%% Bucla deschisa (treapta de factor de umplere mu0 = Uout/Uin)
[yo, to] = step(mu0*Hp, 0:1e-5:0.12);
f = figure('Color', 'w', 'Position', [0 0 1562 831]/2.2);
plot(to*1e3, yo, 'LineWidth', 1.5); hold on; linii_banda(u_out, banda); grid on; box on; xlim([0 120]);
xlabel('t [ms]'); ylabel('u_{out} [V]');
title(sprintf('Procesul in bucla deschisa (\\mu = %.4f): \\sigma = %.1f %%, t_r = %.1f ms', mu0, info_ol.Overshoot, info_ol.SettlingTime*1e3));
salveaza(f, '../figures/t3_bucla_deschisa.png', [1562 831]);

%% Schema Simulink
mdl = 'tema3_reglare';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);
add_block('simulink/Sources/Constant',              [mdl '/Uout'], 'Value', 'u_out', 'Position', [40 45 110 75]);
add_block('simulink/Math Operations/Sum',           [mdl '/Sum'], 'Inputs', '|+-', 'IconShape', 'round', 'Position', [175 45 205 75], 'ShowName', 'off');
add_block('simulink/Continuous/Transfer Fcn',       [mdl '/Hc'], 'Numerator', 'num_c', 'Denominator', 'den_c', 'Position', [265 35 355 85]);
add_block('simulink/Discrete/Zero-Order Hold',      [mdl '/ZOH'], 'SampleTime', '1/freq', 'Position', [415 45 445 75], 'ShowName', 'off');
add_block('simulink/Discontinuities/Saturation',    [mdl '/Saturatie'], 'UpperLimit', '1', 'LowerLimit', '0', 'Position', [505 45 535 75], 'ShowName', 'off');
add_block('simulink/Continuous/Transfer Fcn',       [mdl '/Hp'], 'Numerator', 'num', 'Denominator', 'den', 'Position', [595 35 685 85]);
add_line(mdl, 'Uout/1', 'Sum/1');
add_line(mdl, 'Sum/1', 'Hc/1');
add_line(mdl, 'Hc/1', 'ZOH/1');
add_line(mdl, 'ZOH/1', 'Saturatie/1');
add_line(mdl, 'Saturatie/1', 'Hp/1');
add_line(mdl, [705 60; 735 60; 735 135; 190 135; 190 75]);   % reactie de la iesirea Hp la intrarea - a sumatorului
add_line(mdl, [685 60; 705 60]);
% etichete ca in enunt
a1 = Simulink.Annotation(mdl, '1/freq'); a1.Position = [403 85 457 105]; a1.ForegroundColor = 'red'; a1.FontSize = 14;
a2 = Simulink.Annotation(mdl, '0->1');   a2.Position = [496 85 546 105]; a2.ForegroundColor = 'red'; a2.FontSize = 14;
set_param(mdl, 'StopTime', '0.12', 'Solver', 'ode45', 'MaxStep', '1e-5');
save_system(mdl);
print(['-s' mdl], '-dpng', '-r200', '../figures/t3_schema.png');

%% Simulare
% semnale inregistrate doar pentru figuri (iesirea uout si comanda mu); modelul salvat ramane ca in enunt
ph = get_param([mdl '/Hp'], 'PortHandles');        set_param(ph.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'uout');
ps = get_param([mdl '/Saturatie'], 'PortHandles'); set_param(ps.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'mu');
set_param(mdl, 'SignalLogging', 'on', 'SignalLoggingName', 'logsout', 'ReturnWorkspaceOutputs', 'on');
out = sim(mdl);
close_system(mdl, 0);
y  = out.logsout.get('uout').Values;
mu = out.logsout.get('mu').Values;
[r.max, r.sigma, r.tr, r.yss] = performante(y.Time, squeeze(y.Data), u_out, banda);
r.mu_max = max(squeeze(mu.Data));
fprintf('Bucla inchisa: max = %.3f V, sigma = %.2f %%, tr = %.1f ms, yss = %.3f V, mu_max = %.4f\n', r.max, r.sigma, r.tr*1e3, r.yss, r.mu_max);
save('../results/t3_rezultate.mat', 'r');

figura_raspuns(y, r, u_out, banda, sprintf('Bucla inchisa: H_c(s), ZOH T = 1/freq = %.2f ms, H_p(s)', 1e3/freq), '../figures/t3_bucla_inchisa.png');

f = figure('Color', 'w', 'Position', [0 0 1562 825]/2.2);
stairs(mu.Time*1e3, squeeze(mu.Data), 'LineWidth', 1.5); hold on;
yline(mu0, 'k:'); grid on; box on; xlim([0 120]); ylim([0 1]);
xlabel('t [ms]'); ylabel('\mu'); title('Comanda: factorul de umplere dupa ZOH si saturatie');
salveaza(f, '../figures/t3_comanda.png', [1562 825]);

function [ymax, sigma, tr, yss] = performante(t, y, ref, banda)
    yss = mean(y(t >= t(end) - 0.04));
    ymax = max(y); sigma = (ymax - ref)/ref*100;
    k = find(abs(y - ref) > banda, 1, 'last'); tr = t(k + 1);
end

function linii_banda(ref, banda)
    yline(ref, 'k:'); yline(ref + banda, '--', 'Color', [0.6 0.6 0.6]); yline(ref - banda, '--', 'Color', [0.6 0.6 0.6]);
end

function figura_raspuns(ts, r, ref, banda, titlu, fisier)
    t = ts.Time; y = squeeze(ts.Data);
    f = figure('Color', 'w', 'Position', [0 0 1562 831]/2.2);
    plot(t*1e3, y, 'LineWidth', 1.5); hold on; linii_banda(ref, banda);
    [~, im] = max(y); plot(t(im)*1e3, y(im), 'ko', 'MarkerFaceColor', 'k');
    text(t(im)*1e3 + 2, y(im) + 0.6, sprintf('max = %.2f V  (\\sigma = %.2f %%)', r.max, r.sigma));
    xline(r.tr*1e3, 'k-.');
    plot(r.tr*1e3, interp1(t, y, r.tr), 'ko', 'MarkerFaceColor', 'k');
    text(r.tr*1e3 + 2, 8, sprintf('t_r = %.1f ms', r.tr*1e3));
    grid on; box on; xlim([0 120]); ylim([0 ceil(r.max) + 2]);
    xlabel('t [ms]'); ylabel('u_{out} [V]'); title(titlu);
    salveaza(f, fisier, [1562 831]);
end

function salveaza(f, fisier, dim)
    % exporta figura fara margini si o aduce exact la dim = [latime inaltime] pixeli
    exportgraphics(f, fisier, 'Resolution', round(96*dim(1)/f.Position(3)*1.05));
    img = imread(fisier); [h, w, nc] = size(img); r = dim(1)/dim(2);
    H = max(h, round(w/r)); W = max(w, round(h*r));
    canvas = 255*ones(H, W, nc, 'like', img);
    y0 = floor((H - h)/2); x0 = floor((W - w)/2);
    canvas(y0+1:y0+h, x0+1:x0+w, :) = img;
    imwrite(imresize(canvas, [dim(2) dim(1)]), fisier);
    close(f);
end
