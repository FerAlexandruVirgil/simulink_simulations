clear all;
close all;
clc;

Hf = tf(2,[2 1 0]); kf = 2; Tf = 2;

% cautarea perechilor (ts, sigma) care respecta wb <= 1.2 rad/s si cv >= 1.5
gasit = false;
for i = 0.1:0.1:8
    for j = 0.01:0.01:0.1
        sigma = j;
        tsd = i;
        tita = abs(log(sigma)/sqrt(pi^2 + log(sigma)^2));
        wn = 4/(tita*tsd);
        cv = wn/(2*tita);
        wb = wn*sqrt(1-2*tita^2+sqrt(2-4*tita^2+4*tita^4));
        if wb <= 1.2 && cv >= 1.5
            fprintf('ts = %.1f s, sigma = %.2f: wn = %.4f, cv = %.4f, wb = %.4f\n', tsd, sigma, wn, cv, wb);
            if ~gasit                       % se pastreaza prima pereche gasita (cel mai mic ts)
                gasit = true; tita_ales = tita; wn_ales = wn;
            end
        end
    end
end
if gasit
    tita = tita_ales; wn = wn_ales;
else
    % pentru sigma <= 10 % nu exista pereche cu wb <= 1.2 si cv >= 1.5 (ar trebui tita < ~0.27);
    % se proiecteaza cu sigma = 0.1 si ts = 8 s, valorile folosite de varianta initiala a scriptului
    fprintf('Nicio pereche (ts, sigma) nu respecta wb <= 1.2 si cv >= 1.5; se folosesc sigma = 0.1, ts = 8 s\n');
    sigma = 0.1; tsd = 8;
    tita = abs(log(sigma)/sqrt(pi^2 + log(sigma)^2));
    wn = 4/(tita*tsd);
end
cv = wn/(2*tita)
wb = wn*sqrt(1-2*tita^2+sqrt(2-4*tita^2+4*tita^4))
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