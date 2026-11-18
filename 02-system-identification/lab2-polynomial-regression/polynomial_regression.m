%%

load("lab2_13.mat");

%%

plot(id.X,id.Y);
%%
close all
%%
clear all
clc

%%
% declararea matricei de regresie
n = 5;
x = id.X;

phi1 = zeros(length(x), n);

for i =1:n 

phi1(:,i) = x'.^(i-1); 

end

%
Y = id.Y;


%

theta = phi1\Y';


%
yaprox = phi1*theta;


% inspectarea valorilor functiei
plot(id.X, id.Y); hold on
plot(id.X, yaprox');

%%
x = val.X;
Y = val.Y;

phi2 = zeros(length(x), n);

for i =1:n 

phi2(:,i) = x'.^(i+1); 

end

y_aprox_val = phi2*theta;

figure
plot(val.X, val.Y); hold on
plot(val.X, y_aprox_val);

%%
N_id = length(id.X);
MSE_id = 1/N_id*sum((yaprox - id.Y').^2);
%%
N_val = length(val.X);
MSE_val = 1/N_val*sum((y_aprox_val - val.Y').^2);

%%
% Compararea erorilor de identificare și validare
fprintf('MSE identificare: %.6f\n', MSE_id);
fprintf('MSE validare: %.6f\n', MSE_val);
%%

function grad_optim = optimizare(id, val)

optim = Inf;
grad_optim = 0;
mse_vect = zeros(length(val.Y(:,1)));
k=1;
for j = 2:25
 phi_id = zeros(length(id.X), j);
 phi_val = zeros(length(val.X), j);

 for i = 1:j
    phi_id(:, i) = id.X(:).^(i-1);
    phi_val(:, i) = val.X(:).^(i-1);
 end

 theta = phi_id \ id.Y(:);

 y_aprox = phi_val * theta;
 mse = mean((y_aprox - val.Y').^2);

mse_vect(k) = mse;
k=k+1;

if optim > mse
    optim = mse;
    grad_optim = j-1;

end

end
figure
title(num2str(j))
plot(mse_vect,"Color","r"),
hold on
plot(grad_optim, optim, "g*" )
figure
title("y aproximat")
plot(y_aprox, "Color" , "b")
grid on
end

%%
g = optimizare(id, val);