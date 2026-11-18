Hf = tf(100,[1,15,100]);
step(Hf);
%% ex 2
Hf = tf(2,[10,3]);
figure;
step(Hf);
grid on;

Ho = feedback(Hf,1);
figure;
step(Ho);
grid on;

%% ex 3
Hf = tf(1,[2, 1]);
Hc1 = tf(2,1);
Hc2 = tf(2, [1,0 ]);
Hc3 = tf(10,[1,10]);
Hc4 = tf(2, [1,0,0]);

Hd = series(Hc, Hf);
Ho = feedback(Hd, 1);
t = 0:0.1:50;

figure;
step(Ho);
figure
lsim(Ho,t,t);
figure;
lsim(Ho, t.^2,t);

figure;
bode(Hd);
figure;
bode(Ho);

