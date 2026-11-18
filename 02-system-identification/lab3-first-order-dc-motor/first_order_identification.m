%
u = zeros(1,370);
u(31:100)=0.7;
u(171:270)=0.4;
u(301:370)=-0.5;

figure
plot(u); grid on

%
[vel,~, t] = DCMRun.run(u,'port', 'COM5', 'Ts', 1e-2);
%
save('step_dateDCM.mat', 't', 'vel');
%
plot(t,vel);
%
plot(vel);
%
load("step_dateDCM.mat");
%
u_id = u(31:100);
y_id = vel(31:100);
t_id = t(31:100) - t(31);

yss = mean(y_id(end-20:end)); 
K   = yss / 0.7;

i = find(y_id >= 0.632*yss, 1);
T   = t_id(i);
G = tf(K, [T 1]);
G
disp("Valorile pentru T si respectiv K sunt:")
disp(T);
disp(K);

%
u_v = u(171:370);
y_v = vel(171:370);
t_v = 0:0.1:20;
t_v = t_v(1:end-1);
%
y_c = lsim(G, u_v, t_v);

figure
plot(t_v, y_v,'b', t_v, y_c,'r--'); grid on
%
err = y_c(:) - y_v(:);
MSE = mean(err.^2)
fprintf('MSE = %.4f\n', MSE);

%% impuls
u_imp = 0.1*ones(1,350);     
u_imp(31:32) = 1;          
u_imp(131:132) = 1;           
u_imp(231:232) = 1;           
u_imp(331:332) = 1;
%
plot(u_imp);
%
[vel,~,t] = DCMRun.run(u_imp,'port','COM5','Ts',1e-2);
save('impuls_dateDCM.mat','t','u_imp','vel');

%
load('impuls_dateDCM.mat');
%
figure
plot(u_imp)
figure
plot(vel)
%
% 1/alpha = 1 (in cazul meu) => alpha este 1

%
yss = mean(vel(140:150));
K   = yss/0.1;                 

y_id = vel(:);
t_id = (1:numel(y_id))*1e-2;
dv  = y_id - yss;                
[y_max, tmp_max] = max(dv);              
index_de_36_procente = find(dv(tmp_max:end) <= 0.368*y_max, 1)  + tmp_max - 1;
T   = t_id(index_de_36_procente) - t_id(tmp_max);
G = tf(K,[T 1]);
G
disp("Valorile pentru T si respectiv K sunt:")
disp(T);
disp(K);
%
plot(t_id, y_id);

%
uv = u_imp(35:350);
yv = vel(35:350);

tv = (0:numel(uv)-1)*1e-2;

Gs = ss(G);
x0  = K*0.1;                     

y_t = lsim(Gs, uv, tv);


figure
plot(tv, yv,'b', tv, y_t,'r--'); grid on


