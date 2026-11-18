
close all; 
clear all;
clc;
%% P
Hf = tf(3.5,[0.5 1 0]);
sigma = 0.07;
tita = abs(log(sigma)/sqrt(pi^2 + log(sigma)^2));
A = 1/(4*sqrt(2)*tita^2);
AdB = db(A);
bode(Hf);
wf = 1/0.5;
F = 1.85;
N = AdB;
VrpdB = -(F - N);
Vrp = db2mag(VrpdB);
Hcp = Vrp;
Ho = feedback(series(Hcp,Hf),1);
figure
step(Ho);
grid on;
title('Closed-Loop Step Response');
t = 0:0.1:50;
figure
lsim(Ho,t,t);
figure
bode(Ho)

figure
bode(series(Hcp,Hf));

%% PD
Hf = tf(3.5,[0.5 1 0]);
tsp = 3.88;
cvp = 1.25;
wt1 = 1.06;
tspd = 2;
t = 0:0.1:50;
Vrpd = Vrp*(tsp/tspd);

wt2 = wt1*(tsp/tspd);
Td = 0.5;
Tn = Td*(tsp / tspd);
Hcpd = tf([Vrpd*Td Vrpd], [Tn 1]);

Ho = feedback(series(Hcpd,Hf),1);
r = t;
y = lsim(Ho,t,t);
estp = r(end) - y(end);
cv = 1/estp;
%%
figure
step(Ho);

figure
bode(Ho);
title("H inchis");

figure
bode(series(Hcpd,Hf));
title("H direct");


