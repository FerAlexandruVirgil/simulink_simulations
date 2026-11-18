%% Laborator 3 - convertor buck comandat printr-un modulator cu histerezis
% lab3_buck_closed_loop.slx - un modulator cu histerezis (integrator + releu +-0.01, iesire 0/1)
%                             comanda un convertor buck (E = 24 V) modelat cu ecuatiile de stare,
%                             in bucla inchisa cu referinta de 14 V
% Scriptul simuleaza modelul in bucla inchisa (fara sa-l modifice pe disc) si salveaza
% figura ../figures/lab3_buck_hysteresis.png.
clear; close all;
cd(fileparts(mfilename('fullpath')));

mdl = 'lab3_buck_closed_loop';
load_system(mdl);
% semnale inregistrate: curentul prin bobina, tensiunea de iesire, comanda si factorul de umplere
jur = {'Integrator', 'iL'; 'Integrator1', 'uC'; 'Transfer Fcn', 'c'; 'Sum1', 'd'};
for k = 1:size(jur, 1)
    h = get_param([mdl '/' jur{k, 1}], 'PortHandles');
    set_param(h.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', jur{k, 2});
end
o = sim(mdl, 'SignalLogging', 'on', 'SignalLoggingName', 'logsout', 'ReturnWorkspaceOutputs', 'on', 'MaxStep', '1e-4');
close_system(mdl, 0);                                   % modelul de pe disc ramane neschimbat

ls = o.logsout;
g = @(n) deal(ls.get(n).Values.Time, squeeze(ls.get(n).Values.Data));
[tu, uC] = g('uC'); [ti, iL] = g('iL'); [td, d] = g('d');
T_end = tu(end); w = tu >= T_end - 0.5; wd = td >= T_end - 0.5;
Umed = mean(uC(w)); dU = max(uC(w)) - min(uC(w)); dmed = mean(d(wd));
fprintf('Regim stationar: Umed = %.3f V (referinta 14 V), riplu = %.3f V, d mediu = %.4f\n', Umed, dU, dmed);
% numarul de comutari pe secunda in regim stationar
nsw = sum(diff(d(wd)) > 0.5) / 0.5;
fprintf('Frecventa de comutatie ~ %.0f Hz\n', nsw);

f = figure('Color', 'w', 'Position', [100 100 1200 650]);
subplot(2, 2, [1 2]);
plot(tu, uC, 'LineWidth', 1.3); hold on; yline(14, 'k:', 'referinta 14 V', 'LabelVerticalAlignment', 'top'); yline(Umed, '--', sprintf('%.2f V', Umed), 'LabelVerticalAlignment', 'bottom');
grid on; box on; xlabel('t [s]'); ylabel('u_C [V]');
title('Tensiunea de iesire in bucla inchisa (modulator cu histerezis)');
subplot(2, 2, 3);
plot(ti, iL, 'LineWidth', 1.2); grid on; box on; xlabel('t [s]'); ylabel('i_L [A]'); title('Curentul prin bobina');
subplot(2, 2, 4);
z = td >= T_end - 0.1;
stairs(td(z), d(z), 'LineWidth', 1.2); hold on; yline(dmed, '--', sprintf('medie %.3f', dmed));
grid on; box on; ylim([-0.1 1.2]); xlabel('t [s]'); ylabel('d');
title('Semnalul de comanda al tranzistorului (ultimele 100 ms)');
exportgraphics(f, '../figures/lab3_buck_hysteresis.png', 'Resolution', 150);
