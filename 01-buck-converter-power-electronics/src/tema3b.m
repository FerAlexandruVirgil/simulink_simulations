%% Tema 3.B - validarea regulatorului pe modelul Simscape cu toate elementele reziduale
% Construieste schema din enunt (ProjectDocu_Part3, 3.B) cu subsistemele transistor_driver,
% current_senzor, voltage_sensor si generator_pwm:
%   tema3b_simscape.slx        - cu regulator: Uout -> (+/-) -> Hc -> PWM generator -> Transistor driver
%   tema3b_fara_regulator.slx  - acelasi convertor, factor de umplere constant mu0
% Salveaza figurile t3b_*.png si rezultatele in ../results/t3b_rezultate.mat.
clear; close all;
cd(fileparts(mfilename('fullpath')));
tema3;                                   % Hp, Hc (num_c, den_c), u_in, u_out, freq, R
Tp  = 1/freq;
mu0 = u_out/u_in;

%% Componente reale (Tema 2) - toate elementele reziduale
L_nom = 2.5e-3;   C_nom = 1800e-6;       % Hammond 195E30, Nichicon LGU1H182MELZ
Vf    = 0.46;     Ron_d = 0.001;         % 90SQ045: VF tipic la 9 A
ESR   = 0.30/(2*pi*120*C_nom);           % din tan(delta) = 0.30 la 120 Hz -> ~0.221 Ohm
DCR   = 0.013;                           % 195E30 (Digi-Key: 13 mOhm)
tolC  = 20;  tolL = 15;                  % toleranta minima aplicata (%)
BF_T1 = 1000;                            % PNP: hFE min = 1000 (Datasheet_tranzistor)
U_pwm = 5;                               % amplitudinea PWM (Annex 2)
T_sim = 0.15;

%% Modele
construieste('tema3b_simscape', true);
print('-stema3b_simscape', '-dpng', '-r150', '../figures/t3b_schema.png');
construieste('tema3b_fara_regulator', false);

%% Simulari: fara regulator (mu0 constant) si cu regulator
modele = {'tema3b_fara_regulator', 'tema3b_simscape'}; cazuri = {'fara', 'cu'};
for k = 1:2
    o = sim(modele{k}, 'SrcWorkspace', 'current');
    ls = o.logsout;
    yu = ls.get('uout').Values; yi = ls.get('iL').Values; ym = ls.get('mu').Values;
    r = struct('caz', cazuri{k});
    r.t = yu.Time; r.u = squeeze(yu.Data);
    r.tm = ym.Time; r.mu = squeeze(ym.Data); if isscalar(r.mu), r.tm = [0; T_sim]; r.mu = [r.mu; r.mu]; end
    ti = yi.Time; i = squeeze(yi.Data);
    ws = r.t >= T_sim - 0.03; wi = ti >= T_sim - 0.03; wm = r.tm >= T_sim - 0.03;
    r.Umed = mean(r.u(ws)); r.dU = max(r.u(ws)) - min(r.u(ws)); r.dI = max(i(wi)) - min(i(wi));
    r.mu_ss = mean(r.mu(wm)); r.mu_max = max(r.mu); r.mu0 = r.mu(1);
    % tensiunea medie pe o perioada PWM (fara riplu) -> suprareglaj si timp de raspuns
    tg = (0:1e-5:T_sim)'; ug = interp1(r.t, r.u, tg);
    n = round(Tp/1e-5); um = movmean(ug, [n-1 0]); um(1:n-1) = NaN;
    r.tg = tg; r.um = um;
    r.Umax_med = max(um); r.sigma = max(0, (r.Umax_med - r.Umed)/r.Umed*100);
    kb = find(abs(um - r.Umed) > 0.02*r.Umed, 1, 'last'); r.tr = tg(kb + 1);
    rez(k) = r; %#ok<SAGROW>
    fprintf('%-4s regulator: Umed = %.3f V, dU = %.3f V, dI = %.2f A, Umax(medie) = %.3f V, sigma = %.2f %%, tr = %.1f ms, mu(0) = %.4f, mu_ss = %.4f, mu_max = %.4f\n', ...
        cazuri{k}, r.Umed, r.dU, r.dI, r.Umax_med, r.sigma, r.tr*1e3, r.mu0, r.mu_ss, r.mu_max);
end
close_system('tema3b_simscape', 0); close_system('tema3b_fara_regulator', 0);
rez_salvat = rmfield(rez, {'t', 'u', 'tm', 'mu', 'tg', 'um'}); save('../results/t3b_rezultate.mat', 'rez_salvat', 'mu0');

%% Figuri
culori = colororder;
f = figure('Color', 'w', 'Position', [0 0 2037 794]/2.2);
tl = tiledlayout(f, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile(tl); hold on; grid on; box on;
for k = 1:2, plot(rez(k).t*1e3, rez(k).u, 'Color', [culori(k,:) 0.35], 'LineWidth', 0.8); end
for k = 1:2, plot(rez(k).tg*1e3, rez(k).um, 'Color', culori(k,:), 'LineWidth', 2); end
yline(u_out, 'k:'); xlim([0 T_sim*1e3]); xlabel('t [ms]'); ylabel('u_{out} [V]');
title('Regim tranzitoriu'); subtitle('linie groasa: media pe o perioada PWM');
nexttile(tl); hold on; grid on; box on;
for k = 1:2
    w = rez(k).t >= T_sim - 4*Tp; plot((rez(k).t(w) - (T_sim - 4*Tp))*1e3, rez(k).u(w), 'Color', culori(k,:), 'LineWidth', 1.5);
end
yline(u_out, 'k:'); xlim([0 4*Tp*1e3]); xlabel('t [ms]'); ylabel('u_{out} [V]'); title('Regim stationar (ultimele 4 perioade)');
lg = legend({sprintf('fara regulator (\\mu = %.4f): medie %.2f V', mu0, rez(1).Umed), sprintf('cu regulator H_c: medie %.2f V', rez(2).Umed)}, 'Orientation', 'horizontal');
lg.Layout.Tile = 'south';
salveaza(f, '../figures/t3b_tensiune.png', [2037 794]);

f = figure('Color', 'w', 'Position', [0 0 1562 825]/2.2); hold on; grid on; box on;
plot(rez(2).tm*1e3, rez(2).mu, 'Color', culori(2,:), 'LineWidth', 1.5);
plot(rez(1).tm*1e3, rez(1).mu, 'Color', culori(1,:), 'LineWidth', 1.5);
xlim([0 T_sim*1e3]); ylim([0 0.6]); xlabel('t [ms]'); ylabel('\mu');
title('Comanda: iesirea regulatorului H_c');
legend({sprintf('cu regulator H_c (regim stationar %.4f)', rez(2).mu_ss), sprintf('fara regulator, constant %.4f', mu0)}, 'Location', 'southeast');
salveaza(f, '../figures/t3b_comanda.png', [1562 825]);

%% ------------------------------------------------------------------------------------------
function construieste(mdl, cu_regulator)
% construieste schema din enunt; cu_regulator = false -> mu0 constant in locul buclei de reglare
    if bdIsLoaded(mdl), close_system(mdl, 0); end
    if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
    new_system(mdl); load_system('fl_lib'); load_system('ee_lib'); load_system('nesl_utility');
    surse = {'transistor_driver', 'current_senzor', 'voltage_sensor', 'generator_pwm'};
    for k = 1:numel(surse), load_system(surse{k}); end
    set_param(mdl, 'Solver', 'ode23t', 'MaxStep', '2e-6', 'RelTol', '1e-4', 'StopTime', 'T_sim', ...
        'SignalLogging', 'on', 'SignalLoggingName', 'logsout', 'ReturnWorkspaceOutputs', 'on');
    s = 1.6;                                            % scara fata de figura din enunt
    poz = @(x1, y1, x2, y2) round(s*[x1 y1 x2 y2]);
    blk = @(nume, lib, p, varargin) add_block(lib, [mdl '/' nume], 'Position', p, varargin{:});

    % --- partea de putere
    blk('Solver Configuration', 'nesl_utility/Solver Configuration', poz(290, 105, 336, 135));
    blk('DC Voltage Source',  'fl_lib/Electrical/Electrical Sources/DC Voltage Source', poz(378, 140, 398, 180));
    blk('Electrical Reference',  'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(378, 215, 398, 230));
    blk('PNP Bipolar Transistor', 'ee_lib/Semiconductors & Converters/PNP Bipolar Transistor', poz(530, 130, 570, 160), 'Orientation', 'up');
    blk('Current Sensor',     'current_senzor/Subsystem', poz(585, 105, 625, 140));
    blk('Diode',              'fl_lib/Electrical/Electrical Elements/Diode', poz(645, 165, 665, 200), 'Orientation', 'up');
    blk('Electrical Reference1', 'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(645, 215, 665, 230));
    blk('Current Sensor1',    'current_senzor/Subsystem', poz(670, 105, 710, 140));
    blk('Inductor',           'ee_lib/Passive/Inductor', poz(735, 112, 775, 128));
    blk('Capacitor',          'ee_lib/Passive/Capacitor', poz(787, 150, 807, 190), 'Orientation', 'down');
    blk('Electrical Reference2', 'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(787, 215, 807, 230));
    blk('Resistor',           'fl_lib/Electrical/Electrical Elements/Resistor', poz(866, 150, 886, 190), 'Orientation', 'down');
    blk('Electrical Reference3', 'fl_lib/Electrical/Electrical Elements/Electrical Reference', poz(866, 215, 886, 230));
    blk('VoltageSensor',      'voltage_sensor/Subsystem1', poz(905, 108, 945, 132));
    blk('VoltageSensor2',     'voltage_sensor/Subsystem1', poz(797, 38, 840, 62));
    blk('Scope',  'simulink/Sinks/Scope', poz(628, 62, 660, 82));
    blk('Scope1', 'simulink/Sinks/Scope', poz(712, 62, 745, 82));
    blk('Scope2', 'simulink/Sinks/Scope', poz(868, 40, 900, 60));
    blk('Scope3', 'simulink/Sinks/Scope', poz(1012, 108, 1045, 132));
    % --- comanda
    blk('PWM generator',      'generator_pwm/Subsystem', poz(295, 318, 397, 346));
    blk('Transistor driver',  'transistor_driver/Subsystem', poz(463, 303, 595, 370));
    if cu_regulator
        blk('Uout', 'simulink/Sources/Constant', poz(55, 315, 85, 340), 'Value', 'u_out');
        blk('Sum',  'simulink/Math Operations/Sum', poz(128, 318, 160, 350), 'Inputs', '+-', 'IconShape', 'rectangular');
        blk('Hc',   'simulink/Continuous/Transfer Fcn', poz(197, 318, 257, 346), 'Numerator', 'num_c', 'Denominator', 'den_c');
    else
        blk('mu0',  'simulink/Sources/Constant', poz(197, 318, 257, 346), 'Value', 'mu0');
    end
    for k = 1:numel(surse), close_system(surse{k}, 0); end

    % generatorul PWM: factorul de umplere devine intrarea Mu (in original era constanta mu)
    g = [mdl '/PWM generator'];
    pc = get_param([g '/Constant3'], 'PortHandles'); delete_line(get_param(pc.Outport(1), 'Line'));
    p0 = get_param([g '/Constant3'], 'Position'); delete_block([g '/Constant3']);
    add_block('simulink/Sources/In1', [g '/Mu'], 'Position', p0);
    add_line(g, 'Mu/1', 'GreaterThanOrEqual1/1');
    set_param([g '/Out1'], 'Name', 'PWM signal [0-1]');
    % driverul: porturi denumite ca in enunt; rezistentele raman cele din transistor_driver.slx
    d = [mdl '/Transistor driver'];
    set_param([d '/In1'], 'Name', 'PWM signal');
    set_param([d '/Connection Port'], 'Name', 'Emitter');
    set_param([d '/Connection Port1'], 'Name', 'Base');
    set_param([d '/Gain'], 'Gain', 'U_pwm');           % PWM 0/5 V (Annex 2)

    set_param([mdl '/DC Voltage Source'], 'v0', 'u_in');
    set_param([mdl '/PNP Bipolar Transistor'], 'BF', 'BF_T1', 'hfe', 'BF_T1');
    set_param([mdl '/Diode'], 'Vf', 'Vf', 'Ron', 'Ron_d', 'Goff', '1e-8');
    set_param([mdl '/Inductor'], 'l', 'L_nom', 'r', 'DCR', 'enable_L_tol', 'ee.enum.toleranceApplication.applyMin', 'L_tol', 'tolL');
    set_param([mdl '/Capacitor'], 'c', 'C_nom', 'r', 'ESR', 'g', '0', 'enable_C_tol', 'ee.enum.toleranceApplication.applyMin', 'C_tol', 'tolC');
    set_param([mdl '/Resistor'], 'R', 'R');

    % --- legaturi Simulink
    al = @(a, b) add_line(mdl, a, b, 'autorouting', 'on');
    if cu_regulator
        al('Uout/1', 'Sum/1'); al('Sum/1', 'Hc/1'); al('Hc/1', 'PWM generator/1');
        al('VoltageSensor/1', 'Sum/2');                 % reactia de la senzorul de tensiune
        sursa_mu = 'Hc';
    else
        al('mu0/1', 'PWM generator/1');
        sursa_mu = 'mu0';
    end
    al('PWM generator/1', 'Transistor driver/1');
    al('Current Sensor/1', 'Scope/1'); al('Current Sensor1/1', 'Scope1/1');
    al('VoltageSensor2/1', 'Scope2/1'); al('VoltageSensor/1', 'Scope3/1');
    % semnale salvate: tensiunea de iesire, curentul prin bobina si comanda
    jur = {'VoltageSensor', 'uout'; 'Current Sensor1', 'iL'; sursa_mu, 'mu'};
    for k = 1:size(jur, 1)
        h = get_param([mdl '/' jur{k, 1}], 'PortHandles');
        set_param(h.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', jur{k, 2});
    end

    % --- legaturi fizice
    ph = @(b) get_param([mdl '/' b], 'PortHandles');
    cn = @(a, b) add_line(mdl, a, b, 'autorouting', 'on');
    T1 = ph('PNP Bipolar Transistor');                  % LConn1 = baza; RConn1 = emitor, RConn2 = colector
    Dr = ph('Transistor driver');                       % LConn1 = Emitter, LConn2 = Base
    S1 = ph('Current Sensor'); S2 = ph('Current Sensor1');
    cn(ph('Solver Configuration').RConn(1), ph('DC Voltage Source').LConn(1));
    cn(ph('DC Voltage Source').LConn(1), T1.RConn(1));  % + sursa -> emitor
    cn(Dr.LConn(1), T1.RConn(1));                       % Emitter (driver) -> emitor
    cn(Dr.LConn(2), T1.LConn(1));                       % Base (driver) -> baza
    cn(ph('DC Voltage Source').RConn(1), ph('Electrical Reference').LConn(1));
    cn(T1.RConn(2), S1.LConn(1));                       % colector -> Current Sensor
    cn(S1.RConn(1), S2.LConn(1));                       % -> nodul de comutatie -> Current Sensor1
    cn(S1.RConn(1), ph('Diode').RConn(1));              % catodul diodei la nodul de comutatie
    cn(ph('Diode').LConn(1), ph('Electrical Reference1').LConn(1));
    cn(S1.RConn(1), ph('VoltageSensor2').LConn(1));     % tensiunea nodului de comutatie
    cn(S2.RConn(1), ph('Inductor').LConn(1));
    cn(ph('Inductor').RConn(1), ph('Capacitor').LConn(1));
    cn(ph('Capacitor').RConn(1), ph('Electrical Reference2').LConn(1));
    cn(ph('Inductor').RConn(1), ph('Resistor').LConn(1));
    cn(ph('Resistor').RConn(1), ph('Electrical Reference3').LConn(1));
    cn(ph('Resistor').LConn(1), ph('VoltageSensor').LConn(1));
    save_system(mdl);
end

function salveaza(f, fisier, dim)
    exportgraphics(f, fisier, 'Resolution', round(96*dim(1)/f.Position(3)*1.05));
    img = imread(fisier); [h, w, nc] = size(img); r = dim(1)/dim(2);
    H = max(h, round(w/r)); W = max(w, round(h*r));
    canvas = 255*ones(H, W, nc, 'like', img);
    y0 = floor((H - h)/2); x0 = floor((W - w)/2);
    canvas(y0+1:y0+h, x0+1:x0+w, :) = img;
    imwrite(imresize(canvas, [dim(2) dim(1)]), fisier);
    close(f);
end
