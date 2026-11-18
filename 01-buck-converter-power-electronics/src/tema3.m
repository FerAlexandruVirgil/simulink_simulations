%% Date
u_in  = 48;            % V   - tensiunea sursei
u_out = 20;            % V   - tensiunea de iesire dorita (referinta)
freq  = 800;           % Hz  - frecventa PWM (perioada ZOH = 1/freq)
R     = u_out/16;      % Ohm - sarcina (I_out_max = 16 A)
L     = 2.5e-3;        % H   - Hammond 195E30 (valoare din datasheet)
C     = 1800e-6;       % F   - Nichicon LGU1H182MELZ (valoare din datasheet)

%% 1. Modelul procesului in spatiul starilor
% x = [iL; uC], intrare = factorul de umplere mu (0..1), iesire y = uC
% diL/dt = (mu*u_in - uC)/L,  duC/dt = (iL - uC/R)/C
A = [0      -1/L;
     1/C    -1/(R*C)];
B = [u_in/L; 0];
Cm = [0 1];
D  = 0;

%% 2. Functia de transfer a procesului
[num, den] = ss2tf(A, B, Cm, D);
Hp = tf(num, den);
wn_p   = sqrt(den(3));                   % pulsatia naturala a procesului
zeta_p = den(2)/(2*wn_p);                % amortizarea procesului
fprintf('Hp(s) = %.6g / (s^2 + %.6g s + %.6g)\n', num(end), den(2), den(3));
fprintf('Proces: wn = %.2f rad/s, zeta = %.4f\n', wn_p, zeta_p);
mu0 = u_out/u_in;                        % factorul de umplere nominal
info_ol = stepinfo(mu0*Hp, 'SettlingTimeThreshold', 0.02);
fprintf('Bucla deschisa (mu = %.4f): suprareglaj = %.2f %%, tr(2%%) = %.4f s\n', mu0, info_ol.Overshoot, info_ol.SettlingTime);

%% 3. Performante impuse -> sistemul in bucla inchisa (forma normala de ordin 2)
sigma_imp = 0.001;                                      % suprareglaj impus: 0,1 % (foarte mic, dar nenul; cu ZOH rezulta < 1 %)
tr_imp    = 0.02;                                       % timp de raspuns impus (banda 2 %): 20 ms = 16 perioade PWM
zeta = abs(log(sigma_imp))/sqrt(log(sigma_imp)^2 + pi^2);  % amortizarea din suprareglajul impus
wn   = 4/(zeta*tr_imp);                                 % pulsatia naturala din timpul de raspuns
H0   = tf(wn^2, [1 2*zeta*wn wn^2]);
fprintf('Impus: sigma = %.1f %%, tr = %.3f s -> zeta = %.4f, wn = %.2f rad/s\n', sigma_imp*100, tr_imp, zeta, wn);

%% 4. Functia de transfer a regulatorului: Hc = 1/Hp * H0/(1 - H0)
Hc = minreal(series(1/Hp, H0/(1 - H0)), 1e-6);
[num_c, den_c] = tfdata(Hc, 'v');
fprintf('Hc(s): num = [%s], den = [%s]\n', num2str(num_c, '%.6g  '), num2str(den_c, '%.6g  '));
