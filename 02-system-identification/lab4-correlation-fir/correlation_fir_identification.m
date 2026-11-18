%% 
achizitie = false;   % true doar cu motorul conectat (necesita toolbox-ul DCMRun al laboratorului)

ts = 0.01;
n  = 30;      
Nid = 500;    
nv = 70;  
%%
if achizitie
    u = [zeros(n,1); 1.4*rand(Nid,1)-0.7; zeros(n,1); 0.2*ones(nv,1)];
    [y, ~, t] = DCMRun.run(u, 'port', 'com5', 'Ts', ts);
    save('lab4_dateDCM.mat', 'u', 'y', 't');
end
%%
load('lab4_dateDCM.mat');

u = u(:); 
y = y(:);

idx_id  = n+1 : n+Nid;
idx_val = n+Nid+1 : length(u);

u_id = u(idx_id);   
y_id = y(idx_id);

% 2.
figure; 
subplot(211); plot(u); title('u'); 
subplot(212); plot(y); title('y');

fprintf('medie u_id = %.4f, medie y_id = %.4f\n', mean(u_id), mean(y_id));

u_id = u_id - mean(u_id);      
y_id = y_id - mean(y_id);

% 3.
N = length(u_id);
ru  = zeros(N,1);
ryu = zeros(N,1);
for tau = 0:N-1
    k = 1:N-tau;
    ru(tau+1)  = sum(u_id(k+tau) .* u_id(k)) / N;
    ryu(tau+1) = sum(y_id(k+tau) .* u_id(k)) / N;
end
figure; subplot(211); plot(ru); title('r_u'); 
subplot(212); plot(ryu); title('r_yu');

% 4.
M = 60;      
T = N;        

Phi = zeros(T, M);
for i = 1:T
    for j = 1:M
        Phi(i,j) = ru(abs(i-j) + 1);   
    end
end
h = Phi \ ryu;

figure; stem(h); 

% 5.
yhat = conv(h, u);
yhat = yhat(1:length(u));
t_sim = (0:length(u)-1)' * ts;

figure;
plot(t_sim, y);
hold on;
plot(t_sim, yhat);
xline(t_sim(idx_val(1)), '--');

mse_id  = mean((y(idx_id)  - yhat(idx_id)).^2);
mse_val = mean((y(idx_val) - yhat(idx_val)).^2);
fprintf('M = %d: MSE id = %.5f, MSE val = %.5f\n', M, mse_id, mse_val);

% 6.
Ms = 5:5:150;
mse_id_all = zeros(size(Ms)); 
mse_val_all = zeros(size(Ms));
for q = 1:length(Ms)
    Mq = Ms(q);
    Phi = zeros(T, Mq);
    for i = 1:T
        for j = 1:Mq
            Phi(i,j) = ru(abs(i-j) + 1);
        end
    end
    hq = Phi \ ryu(1:T);
    yh = conv(hq, u); yh = yh(1:length(u));


    mse_id_all(q)  = mean((y(idx_id)  - yh(idx_id)).^2);
    mse_val_all(q) = mean((y(idx_val) - yh(idx_val)).^2);
end


figure; 
plot(Ms, mse_id_all, '-o', Ms, mse_val_all, '-o');
xlabel('M'); ylabel('MSE');