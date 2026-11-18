clear all;
close all;
clc;

Hf = tf(2,[2 1 0]); kf = 2; Tf = 2;

for i = 0:0.1:8
    for j = 0:0.01:0.1
sigma = j;
tsd = i;
tita = abs(log(sigma)/sqrt(pi^2 + log(sigma)^2));
wn = 4/(tita*tsd);
cv = wn/(2*tita)
wb = wn*sqrt(1-2*tita^2+sqrt(2-4*tita^2+4*tita^3))
    end
    if wb <= 1.2 && cv>=1.5
        fprintf()
    end
end
Hc = tf([(Tf*wn)/(2*tita) wn/(2*tita)],[kf/(2*tita*wn) kf]);
Hd = series(Hc,Hf);
Ho = feedback(Hd,1);
%%
figure
step(Ho);
t = 0:0.1:50;
figure
lsim(Ho,t,t);
figure
bode(Ho);