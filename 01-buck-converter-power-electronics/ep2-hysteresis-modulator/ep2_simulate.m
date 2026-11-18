%% EP 2 - modulator cu histerezis (sigma-delta)
% ep2_modulator.slx: comanda trece prin 0.5/(s+1), apoi un integrator al erorii (comanda - 10*releu)
% urmat de un releu cu histerezis (+-0.01, iesire +-0.5); la iesirea releului se adauga 0.5,
% deci semnalul de comanda al tranzistorului d este 0/1.
% In model intrarea functiei de transfer nu este conectata (comanda = 0). Scriptul:
%   1) simuleaza modelul asa cum este salvat;
%   2) conecteaza, doar in memorie, o comanda in trepte la intrare, ca sa arate ca valoarea
%      medie a lui d urmareste 0.5 + c/10 (c = iesirea functiei de transfer).
% Modelul de pe disc ramane neschimbat. Figura: ../figures/ep2_hysteresis_modulator.png
clear; close all;
cd(fileparts(mfilename('fullpath')));

mdl = 'ep2_modulator';
load_system(mdl);
fprintf('Constanta adunata la iesirea releului: %s\n', get_param([mdl '/Constant'], 'Value'));
jur = {'Transfer Fcn', 'c'; 'Integrator2', 'x'; 'Sum1', 'd'};
for k = 1:size(jur, 1)
    h = get_param([mdl '/' jur{k, 1}], 'PortHandles');
    set_param(h.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', jur{k, 2});
end
optiuni = {'SignalLogging', 'on', 'SignalLoggingName', 'logsout', 'ReturnWorkspaceOutputs', 'on', 'MaxStep', '1e-4'};

%% 1) modelul asa cum este salvat (intrare neconectata)
o1 = sim(mdl, optiuni{:});
[t1, d1] = semnal(o1, 'd');
w = t1 >= t1(end) - 1;
fprintf('Model salvat: d mediu = %.4f, frecventa de comutatie ~ %.0f Hz\n', mean_t(t1(w), d1(w)), sum(diff(d1(w)) > 0.5));

%% 2) comanda in trepte (doar in memorie)
cmd = [0 0; 3 0; 3 4; 6.5 4; 6.5 -6; 10 -6];       % intrarea functiei de transfer
add_block('simulink/Sources/From Workspace', [mdl '/cmd'], 'VariableName', 'cmd', 'Interpolate', 'off', ...
    'OutputAfterFinalValue', 'Holding final value');
add_line(mdl, 'cmd/1', 'Transfer Fcn/1');
o2 = sim(mdl, optiuni{:}, 'SrcWorkspace', 'current');
close_system(mdl, 0);

[tc, c] = semnal(o2, 'c'); [td, d] = semnal(o2, 'd');
tu = (0:1e-4:td(end))';
du = interp1(td, d, tu, 'previous');
dm = movmean(du, round(0.2/1e-4));                  % media pe 200 ms (~25 perioade de comutatie)
dteor = 0.5 + interp1(tc, c, tu)/10;
for tt = [2.9 6.4 9.9]
    k = find(tu >= tt, 1);
    fprintf('t = %.1f s: c = %.3f, d mediu = %.4f, 0.5 + c/10 = %.4f\n', tt, interp1(tc, c, tt), dm(k), dteor(k));
end

f = figure('Color', 'w', 'Position', [100 100 1200 650]);
subplot(2, 3, [1 2 3]);
plot(tu, dm, 'LineWidth', 1.4); hold on; plot(tu, dteor, '--', 'LineWidth', 1.4);
grid on; box on; ylim([0 1]); xlabel('t [s]'); ylabel('d');
legend({'media lui d pe 200 ms', '0.5 + c/10'}, 'Location', 'northeast');
title('Valoarea medie a semnalului de comanda urmareste comanda c');
ferestre = [2.95 3.0; 6.45 6.5; 9.95 10.0];
for k = 1:3
    subplot(2, 3, 3 + k);
    z = td >= ferestre(k, 1) & td <= ferestre(k, 2);
    stairs(td(z), d(z), 'LineWidth', 1.2); grid on; box on; ylim([-0.1 1.2]); xlim(ferestre(k, :));
    xlabel('t [s]'); ylabel('d');
    % integratorul urca cu panta c+5 si coboara cu c-5 intre pragurile +-0.01 (banda 0.02):
    % t_on = 0.02/(5-c), t_off = 0.02/(5+c)  =>  d = 0.5 + c/10,  f = (25 - c^2)/0.2 = 125 - 5c^2
    ck = interp1(tc, c, mean(ferestre(k, :)));
    title(sprintf('c = %.2f:  d = %.2f,  f = 125 - 5c^2 = %.0f Hz', ck, 0.5 + ck/10, 125 - 5*ck^2));
end
exportgraphics(f, '../figures/ep2_hysteresis_modulator.png', 'Resolution', 150);

function [t, y] = semnal(o, nume)
    v = o.logsout.get(nume).Values;
    t = v.Time; y = squeeze(v.Data);
end

function m = mean_t(t, y)                           % media in timp a unui semnal in trepte
    m = sum(y(1:end-1).*diff(t)) / (t(end) - t(1));
end
