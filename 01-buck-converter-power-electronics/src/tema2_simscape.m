%% Tema 2 - model Simscape al convertorului buck, scenariile a) si b) ... b.v)
% Construieste tema2_model.slx dupa schema din enunt (ProjectDocu_Part2 / Annex 2), cu subsistemele
% generator_pwm, transistor_driver, current_senzor si voltage_sensor si tranzistor PNP.
% Fiecare subpunct b) porneste de la cazul ideal a) si inlocuieste o singura valoare ideala cu cea reala.
% Salveaza figurile t2_*.png, schema t2_schema.png si rezultatele in ../results/t2_rezultate.mat.
clear; close all;
cd(fileparts(mfilename('fullpath')));

%% Date
u_in = 48; u_out = 20; fs = 800; Tp = 1/fs; mu = u_out/u_in; R = u_out/16;
L_calc = 2.604e-3;  C_calc = 2187.5e-6;          % Tema 1, valori calculate
L_nom  = 2.5e-3;    C_nom  = 1800e-6;            % Hammond 195E30, Nichicon LGU1H182MELZ
Vf_ideal = 0.1;     Ron_d = 0.001;               % dioda aproape ideala
Vf_real  = 0.46;                                 % 90SQ045: VF tipic la 9 A, 25 grd C
tan_d    = 0.30;                                 % Nichicon LGU, 50 V, 120 Hz
ESR      = tan_d/(2*pi*120*C_nom);               % ~0.221 Ohm
DCR      = 0.013;                                % Hammond 195E30 (Digi-Key: 13 mOhm)
tolC = 20; tolL = 15;                            % toleranta minima (%)
BF_T1 = 1000;                                    % PNP: hFE min = 1000 (Datasheet_tranzistor)
U_pwm = 5;                                       % amplitudinea PWM (Annex 2)
T_sim = 0.2;

%% Construire model (schema din enunt)
mdl = 'tema2_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl); load_system('fl_lib'); load_system('ee_lib'); load_system('nesl_utility');
surse = {'transistor_driver', 'current_senzor', 'voltage_sensor', 'generator_pwm'};
for k = 1:numel(surse), load_system(surse{k}); end
set_param(mdl, 'Solver', 'ode23t', 'MaxStep', '2e-6', 'RelTol', '1e-4', 'StopTime', 'T_sim', ...
    'SignalLogging', 'on', 'SignalLoggingName', 'logsout', 'ReturnWorkspaceOutputs', 'on');
s = 1.6; poz = @(x1, y1, x2, y2) round(s*[x1 y1 x2 y2]);
blk = @(nume, lib, p, varargin) add_block(lib, [mdl '/' nume], 'Position', p, varargin{:});

blk('Solver Configuration',   'nesl_utility/Solver Configuration', poz(35, 112, 82, 140));
blk('DC Voltage Source',      'fl_lib/Electrical/Electrical Sources/DC Voltage Source', poz(131, 145, 151, 185));
blk('Electrical Reference',   'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(131, 228, 151, 243));
blk('PNP Bipolar Transistor', 'ee_lib/Semiconductors & Converters/PNP Bipolar Transistor', poz(295, 135, 335, 165), 'Orientation', 'up');
blk('Current Sensor',         'current_senzor/Subsystem', poz(348, 105, 405, 145));
blk('Diode',                  'fl_lib/Electrical/Electrical Elements/Diode', poz(412, 172, 432, 207), 'Orientation', 'up');
blk('Electrical Reference1',  'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(412, 230, 432, 245));
blk('Current Sensor1',        'current_senzor/Subsystem', poz(438, 105, 495, 145));
blk('Inductor',               'ee_lib/Passive/Inductor', poz(508, 118, 548, 132));
blk('Capacitor',              'ee_lib/Passive/Capacitor', poz(563, 160, 583, 200), 'Orientation', 'down');
blk('Electrical Reference2',  'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(563, 230, 583, 245));
blk('Resistor',               'fl_lib/Electrical/Electrical Elements/Resistor', poz(647, 160, 667, 200), 'Orientation', 'down');
blk('Electrical Reference3',  'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(647, 230, 667, 245));
blk('VoltageSensor',          'voltage_sensor/Subsystem1', poz(688, 112, 735, 140));
blk('VoltageSensor2',         'voltage_sensor/Subsystem1', poz(572, 37, 618, 63));
blk('Scope',  'simulink/Sinks/Scope', poz(395, 58, 425, 80));
blk('Scope1', 'simulink/Sinks/Scope', poz(487, 58, 517, 80));
blk('Scope2', 'simulink/Sinks/Scope', poz(645, 39, 675, 61));
blk('Scope3', 'simulink/Sinks/Scope', poz(765, 112, 795, 134));
blk('PWM generator',     'generator_pwm/Subsystem', poz(40, 337, 152, 368));
blk('Transistor driver', 'transistor_driver/Subsystem', poz(220, 318, 355, 392));
for k = 1:numel(surse), close_system(surse{k}, 0); end

% nume de porturi ca in enunt; generatorul PWM pastreaza constanta mu (factorul de umplere calculat)
set_param([mdl '/PWM generator/Out1'], 'Name', 'PWM signal [0-1]');
d = [mdl '/Transistor driver'];
set_param([d '/In1'], 'Name', 'PWM signal');
set_param([d '/Connection Port'], 'Name', 'Emitter');
set_param([d '/Connection Port1'], 'Name', 'Base');
set_param([d '/Gain'], 'Gain', 'U_pwm');                % PWM 0/5 V (Annex 2); rezistentele raman cele implicite

set_param([mdl '/DC Voltage Source'], 'v0', 'u_in');
set_param([mdl '/PNP Bipolar Transistor'], 'BF', 'BF_T1', 'hfe', 'BF_T1');
set_param([mdl '/Diode'], 'Vf', 'Vf', 'Ron', 'Ron_d', 'Goff', '1e-8');
set_param([mdl '/Inductor'], 'l', 'Lv', 'r', 'DCRv', 'L_tol', num2str(tolL));
set_param([mdl '/Capacitor'], 'c', 'Cv', 'r', 'ESRv', 'g', '0', 'C_tol', num2str(tolC));
set_param([mdl '/Resistor'], 'R', 'R');

% legaturi Simulink
al = @(a, b) add_line(mdl, a, b, 'autorouting', 'on');
al('PWM generator/1', 'Transistor driver/1');
al('Current Sensor/1', 'Scope/1'); al('Current Sensor1/1', 'Scope1/1');
al('VoltageSensor2/1', 'Scope2/1'); al('VoltageSensor/1', 'Scope3/1');
jur = {'VoltageSensor', 'uout'; 'Current Sensor1', 'iL'};
for k = 1:size(jur, 1)
    h = get_param([mdl '/' jur{k, 1}], 'PortHandles');
    set_param(h.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', jur{k, 2});
end
% legaturi fizice
ph = @(b) get_param([mdl '/' b], 'PortHandles');
cn = @(a, b) add_line(mdl, a, b, 'autorouting', 'on');
T1 = ph('PNP Bipolar Transistor');                  % LConn1 = baza; RConn1 = emitor, RConn2 = colector
Dr = ph('Transistor driver');                       % LConn1 = Emitter, LConn2 = Base
S1 = ph('Current Sensor'); S2 = ph('Current Sensor1');
cn(ph('Solver Configuration').RConn(1), ph('DC Voltage Source').LConn(1));
cn(ph('DC Voltage Source').LConn(1), T1.RConn(1));
cn(Dr.LConn(1), T1.RConn(1));
cn(Dr.LConn(2), T1.LConn(1));
cn(ph('DC Voltage Source').RConn(1), ph('Electrical Reference').LConn(1));
cn(T1.RConn(2), S1.LConn(1));
cn(S1.RConn(1), S2.LConn(1));
cn(S1.RConn(1), ph('Diode').RConn(1));
cn(ph('Diode').LConn(1), ph('Electrical Reference1').LConn(1));
cn(S1.RConn(1), ph('VoltageSensor2').LConn(1));
cn(S2.RConn(1), ph('Inductor').LConn(1));
cn(ph('Inductor').RConn(1), ph('Capacitor').LConn(1));
cn(ph('Capacitor').RConn(1), ph('Electrical Reference2').LConn(1));
cn(ph('Inductor').RConn(1), ph('Resistor').LConn(1));
cn(ph('Resistor').RConn(1), ph('Electrical Reference3').LConn(1));
cn(ph('Resistor').LConn(1), ph('VoltageSensor').LConn(1));
Lv = L_calc; Cv = C_calc; Vf = Vf_ideal; ESRv = 0; DCRv = 0;   %#ok<NASGU> valori initiale (cazul ideal)
save_system(mdl);
print(['-s' mdl], '-dpng', '-r150', '../figures/t2_schema.png');

%% Scenarii (independente): fiecare subpunct porneste de la cazul ideal a)
% si modifica doar elementul indicat; toleranta se aplica valorii nominale a piesei
sc = struct('id', {'a','b0','b1','b2','b3','b4','b5'}, ...
    'et', {'a) ideal','b) piese reale','b.i)','b.ii)','b.iii)','b.iv)','b.v)'}, ...
    'L', {L_calc, L_nom, L_calc, L_calc, L_calc, L_calc, L_nom}, ...
    'C', {C_calc, C_nom, C_calc, C_calc, C_calc, C_nom, C_calc}, ...
    'Vf', {Vf_ideal, Vf_ideal, Vf_real, Vf_ideal, Vf_ideal, Vf_ideal, Vf_ideal}, ...
    'ESR', {0, 0, 0, ESR, 0, 0, 0}, 'DCR', {0, 0, 0, 0, DCR, 0, 0}, ...
    'tC', {0, 0, 0, 0, 0, 1, 0}, 'tL', {0, 0, 0, 0, 0, 0, 1});
fprintf('ESR = %.4f Ohm\n', ESR);
for k = 1:numel(sc)
    Lv = sc(k).L; Cv = sc(k).C; Vf = sc(k).Vf; ESRv = sc(k).ESR; DCRv = sc(k).DCR; %#ok<NASGU>
    set_param([mdl '/Capacitor'], 'enable_C_tol', tol_opt(sc(k).tC));
    set_param([mdl '/Inductor'], 'enable_L_tol', tol_opt(sc(k).tL));
    o = sim(mdl, 'SrcWorkspace', 'current');
    yu = o.logsout.get('uout').Values; yi = o.logsout.get('iL').Values;
    t = yu.Time; u = squeeze(yu.Data); ti = yi.Time; i = squeeze(yi.Data);
    ws = t >= T_sim - 0.05; wsi = ti >= T_sim - 0.05;
    sc(k).t = t; sc(k).u = u;
    sc(k).Umed = mean(u(ws)); sc(k).dU = max(u(ws)) - min(u(ws));
    sc(k).dI = max(i(wsi)) - min(i(wsi)); sc(k).Umax = max(u);
    fprintf('%-6s Umed = %.3f V  dU = %.4f V  dI = %.3f A  Umax = %.3f V\n', ...
        sc(k).id, sc(k).Umed, sc(k).dU, sc(k).dI, sc(k).Umax);
end
close_system(mdl, 0);
rez = rmfield(sc, {'t', 'u'}); save('../results/t2_rezultate.mat', 'rez');

%% Figuri
for k = 1:numel(sc)
    f = figure('Color', 'w', 'Position', [0 0 2037 794]/2.2);
    lista = unique([1 k]);
    tl = tiledlayout(f, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    for p = 1:2
        nexttile(tl); hold on; grid on; box on;
        for j = lista
            if p == 1
                w = sc(j).t <= 0.06; plot(sc(j).t(w)*1e3, sc(j).u(w), 'LineWidth', 1.5);
            else
                w = sc(j).t >= T_sim - 4*Tp; plot((sc(j).t(w) - (T_sim - 4*Tp))*1e3, sc(j).u(w), 'LineWidth', 1.5);
            end
        end
        xlabel('t [ms]'); ylabel('u_{out} [V]');
        if p == 1, xlim([0 60]); title('Regim tranzitoriu');
        else, xlim([0 4*Tp*1e3]); title('Regim stationar (ultimele 4 perioade)'); end
    end
    et = arrayfun(@(j) sprintf('%s: %.2f V, \\Deltau = %.3f V', sc(j).et, sc(j).Umed, sc(j).dU), lista, 'UniformOutput', false);
    lg = legend(et, 'Orientation', 'horizontal');
    lg.Layout.Tile = 'south';
    salveaza(f, sprintf('../figures/t2_%s.png', sc(k).id), [2037 794]);
end

function s = tol_opt(aplica)
    if aplica, s = 'ee.enum.toleranceApplication.applyMin'; else, s = 'ee.enum.toleranceApplication.none'; end
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
