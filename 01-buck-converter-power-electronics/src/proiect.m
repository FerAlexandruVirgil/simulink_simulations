%% Date de intrare
u_in        = 48;        % V
u_out       = 20;        % V
I_out_max   = 16;        % A
ripple_I_pc = 35;        % % din I_out_max
delta_U_out = 400e-3;    % V
fs          = 800;       % Hz

%% Calcul 
delta_I_l = ripple_I_pc/100 * I_out_max;              % A   -> 5.6 A
mu        = u_out/u_in;                               % factor de umplere -> 0.4167
L         = (u_in - u_out)*mu/(fs*delta_I_l);         % H   -> 2.604 mH
C         = delta_I_l/(8*fs*delta_U_out);             % F   -> 2187.5 uF
I_d       = I_out_max*(1 - mu);                       % A   -> 9.33 A
I_Tmax    = I_out_max + delta_I_l/2;                  % A   -> 18.8 A
R         = u_out/I_out_max;                          % Ohm -> 1.25 Ohm

fprintf('mu = %.4f\nL = %.4g H\nC = %.4g F\nI_D = %.3f A\nI_Tmax = %.2f A\nR = %.3f Ohm\n', ...
        mu, L, C, I_d, I_Tmax, R);

%% Valori nominale ale componentelor alese 
L_real = 2.5e-3;          
C_real = 1800e-6;       