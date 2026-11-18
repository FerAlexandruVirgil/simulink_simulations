%%
clear all;
close all;
clc

%% lab 2 IRA 

t = 0 : 0.01 : 15;

rp = ones(1,length(t));
rv = t;

Hf = tf(1,[1 1 0]);
Hc = tf(12,1);

Hd = series(Hc,Hf); % Calea directa

Ho = feedback(Hd,1); % TF in bucla inchisa

%iesiri
yp = step(Ho,t); 
yv = lsim(Ho, rv, t);
%%
figure;
plot(t, yp, 'b', t, yv, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('Timp [s]');
ylabel('Răspuns');
legend('Răspuns la treaptă', 'Răspuns la rampă', 'Location', 'best');
%%
figure
hold on;
plot(t, rp);
plot(t, yp);

%%
figure
hold on;
plot(t, rv);
plot(t, yv);

%%
estp = rp(end) -  yp(end)
estv = rv(end) - yv(end)


%% lab 2 IRA 

t = 0 : 0.01 : 15;

rp = ones(1,length(t));
rv = t;

Hf = tf(5,[2 1]);
Hc = tf([2,2],[1,0]);

Hd = series(Hc,Hf); % Calea directa

Ho = feedback(Hd,1); % TF in bucla inchisa

%iesiri
yp = step(Ho,t); 
yv = lsim(Ho, rv, t);
%%
figure;
plot(t, yp, 'b', t, yv, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('Timp [s]');
ylabel('Răspuns');
legend('Răspuns la treaptă', 'Răspuns la rampă', 'Location', 'best');
%%
figure
hold on;
plot(t, rp);
plot(t, yp);

%%
figure
hold on;
plot(t, rv);
plot(t, yv);

%%
estp = rp(end) -  yp(end)
estv = rv(end) - yv(end)

