Kf = 1;
Tf = 5;
Hf = tf(Kf,conv([1,0], [Tf,1]));
%ales
delta_sigmac = 0.02;
%ales
sigma = 0.03;
sigma2 = sigma - delta_sigmac;
ts = 6;
tita = abs(log(sigma2)/sqrt(pi^2 + log(sigma2)^2));
wn = 4/(tita*ts);
%ales
cv = 2,5;

pc = delta_sigmac/(2*tita/wn-1/cv);
zc = pc/(1+delta_sigmac);
Ho = tf(wn^2, [1,2*tita,wn^2])*tf([1,zc],[1,pc])*pc/zc;
Hc = 1/Hf*Ho/(1-Ho);

t = 0:0.01:10;
%%
figure
bode(Ho);
figure
step(Ho);
%%
H_simpl = minreal(Hc);
%%

Koef = 3.3215*0.2*0.01267 / 1.66/0.005018;
0.2/1.66


0.01267/0.005018

Hs = zpk(Koef,[])