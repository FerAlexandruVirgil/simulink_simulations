%% Tema 1 - simulari si figuri (simulare1.slx)
% Ruleaza proiect.m (L, C calculate si L_real, C_real), simuleaza simulare1.slx
% si salveaza figurile pentru punctele b) si c) in folderul ../figures.
clear; close all;
cd(fileparts(mfilename('fullpath')));
proiect;
L_mH = L*1e3; Lr_mH = L_real*1e3; C_uF = C*1e6; Cr_uF = C_real*1e6;

mdl = 'simulare1';
load_system(mdl);
sc = find_system(mdl, 'BlockType', 'Scope');
for i = 1:numel(sc)
    set_param(sc{i}, 'DataLogging', 'on', 'DataLoggingVariableName', ['s_' get_param(sc{i}, 'Name')], ...
        'DataLoggingSaveFormat', 'Structure With Time', 'DataLoggingLimitDataPoints', 'off');
end
out = sim(mdl, 'StopTime', '0.5');
close_system(mdl, 0);

% Scope4: uC a)/b) cu PWM; Scope5: iL a)/b) cu PWM; Scope10/11: aceleasi cu mu constant
s4 = out.get('s_Scope4'); s5 = out.get('s_Scope5'); s10 = out.get('s_Scope10'); s11 = out.get('s_Scope11');
Tp = 1/fs;

%% b) regim stationar: ultimele 5 perioade
t = s4.time; w = t >= t(end) - 5*Tp - 1e-9;
ua = s4.signals(1).values(w); ub = s4.signals(2).values(w);
ia = s5.signals(1).values(w); ib = s5.signals(2).values(w);
tw = (t(w) - t(find(w, 1)))*1e3;
dUa = max(ua) - min(ua); dUb = max(ub) - min(ub);
dIa = max(ia) - min(ia); dIb = max(ib) - min(ib);
fprintf('b) dIL: a = %.3f A, b = %.3f A\n', dIa, dIb);
fprintf('b) dUout: a = %.4f V, b = %.4f V\n', dUa, dUb);

f = figure('Color', 'w', 'Position', [0 0 1542 775]/2.2);
plot(tw, ia, 'LineWidth', 1.5); hold on; plot(tw, ib, 'LineWidth', 1.5); grid on; box on;
xlim([0 5*Tp*1e3]); xlabel('t [ms]'); ylabel('i_L [A]'); title('Curentul prin bobina: a) vs b)');
legend(sprintf('a) calculat: L = %.4g mH  (\\Deltai_L = %.2f A)', L_mH, dIa), ...
       sprintf('b) piese reale: L = %.4g mH  (\\Deltai_L = %.2f A)', Lr_mH, dIb), ...
       'Location', 'southoutside', 'Orientation', 'horizontal');
salveaza(f, '../figures/t1_b_iL.png', [1542 775]);

f = figure('Color', 'w', 'Position', [0 0 1579 775]/2.2);
plot(tw, ua, 'LineWidth', 1.5); hold on; plot(tw, ub, 'LineWidth', 1.5); grid on; box on;
xlim([0 5*Tp*1e3]); xlabel('t [ms]'); ylabel('u_{out} [V]'); title('Tensiunea de iesire: a) vs b)');
legend(sprintf('a) calculat: C = %.5g \\muF  (\\Deltau = %.3f V)', C_uF, dUa), ...
       sprintf('b) piese reale: C = %.5g \\muF  (\\Deltau = %.3f V)', Cr_uF, dUb), ...
       'Location', 'southoutside', 'Orientation', 'horizontal');
salveaza(f, '../figures/t1_b_uout.png', [1579 775]);

%% c) factor de umplere constant
t = s10.time; wc = t <= 0.08;
uca = s10.signals(1).values; ucb = s10.signals(2).values;
ica = s11.signals(1).values; icb = s11.signals(2).values;
for k = 1:2
    y = s10.signals(k).values; yf = y(end);
    out_c(k).max = max(y); out_c(k).sigma = (max(y) - yf)/yf*100; %#ok<SAGROW>
    afara = find(abs(y - yf) > 0.02*yf, 1, 'last'); out_c(k).ts = t(afara + 1); %#ok<SAGROW>
    fprintf('c) %s: final = %.3f V, max = %.3f V, sigma = %.2f %%, ts = %.4f s\n', ...
        char('a' + k - 1), yf, out_c(k).max, out_c(k).sigma, out_c(k).ts);
end

f = figure('Color', 'w', 'Position', [0 0 1554 825]/2.2);
plot(t(wc)*1e3, uca(wc), 'LineWidth', 1.5); hold on; plot(t(wc)*1e3, ucb(wc), 'LineWidth', 1.5);
yline(20, 'k:'); yline(20*1.02, '--', 'Color', [0.6 0.6 0.6]); h = yline(20*0.98, '--', 'Color', [0.6 0.6 0.6]);
grid on; box on; xlim([0 80]); xlabel('t [ms]'); ylabel('u_{out} [V]');
title(sprintf('c) Raspuns la factor de umplere constant \\mu = %.4f', mu));
legend({'a) L, C calculate', 'b) piese reale', '20 V', 'banda  \pm2%'}, 'Location', 'southeast');
salveaza(f, '../figures/t1_c_uout.png', [1554 825]);

f = figure('Color', 'w', 'Position', [0 0 1554 825]/2.2);
plot(t(wc)*1e3, ica(wc), 'LineWidth', 1.5); hold on; plot(t(wc)*1e3, icb(wc), 'LineWidth', 1.5);
yline(16, 'k:'); grid on; box on; xlim([0 80]); xlabel('t [ms]'); ylabel('i_L [A]');
title('c) Curentul prin bobina la \mu constant');
legend({'a) L, C calculate', 'b) piese reale', '16 A'}, 'Location', 'southeast');
salveaza(f, '../figures/t1_c_iL.png', [1554 825]);

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
