clear all
close all
clc
%% Ex2
%t = 0:0.01:10;
t = 0:0.1:30;
Hf = tf(5,[2 1]);
%Hc = tf(2,1);
Hc = tf([2 2], [1 0]);
Hory = (Hc*Hf)/(1+Hc*Hf);
Hopy = 1/(1+Hc*Hf);
%p = 0.3*(t.^2);
p = @(t) 0.2*(t<10) + 0.3*((t<20) & (t>=10)) + 0.4*(t>=20);
yr = step(Hory, t);
yp = lsim(Hopy, p(t), t);
yfin = yr + yp;
plot(t,yfin);

%%
t = 0:0.1:30;
p = @(t) 0.2*(t<10) + 0.3*((t<20) & (t>=10)) + 0.4*(t>=20);

figure
plot(t, p(t));
grid on;
%% ex3 
t = 0:0.1:30;
Hf1 = tf(1, [1,0]);
Hf2 = tf(1,[1,2]);
Hc = tf([2 2], [1 0]);
Hory = feedback(Hc*Hf1*Hf2/(1+Hc*Hf1*Hf2), 1);
Hop1y = feedback((Hf1*Hf2)/(1+Hc*Hf1*Hf2), 1);
Hop2y = feedback(Hf2/(Hc*Hf1*Hf2), 1);
yr = step(Hory, t);
yp1 = step(Hop1y,t);
yp2 = step(Hop2y,t);
yfin = yr-yp1-yp2;
plot(t,yfin);

%% ex 4
t = 0:0.1:150;
Hory = tf(3,1);
Hop1y = tf(5,1);
Hop2y = tf(9,1);
yr1 = step(Hory,t);
yr2 = lsim(Hory,t,t);
yp1= 0.2*step(Hop1y,t);
yp2= 0.1*step(Hop2y,t);
yf1 = yr1+yp1-yp2;
yf2 = yr2+yp1-yp2;
plot(t, yf1);
hold on
plot(t, yf2);