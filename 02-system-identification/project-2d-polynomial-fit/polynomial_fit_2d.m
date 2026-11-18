
load("proj_fit_01.mat");

% intrari
inputData1 = id.X{1};
inputData2 = id.X{2};

% iesiri
outputData = id.Y;

%%

n = 7;

N = (n+1)*(n+2)/2;

p = 1;
[x1, x2] = meshgrid(inputData1, inputData2);

X1 = x1(:);
X2 = x2(:);

phi = ones(length(X1), N);
   
for i = 0:n
    for j = 0:(n-i)
        phi(:,p) = X1.^i .* X2.^j;
        p = p+1;
    end
end

iesiri = outputData(:);

theta = phi \ iesiri;

y_aprox = phi * theta;

y_aprox = reshape(y_aprox, size(outputData));
%%
 close all;
 figure
 mesh(y_aprox); grid on
 hold on
 mesh(outputData); grid on
 legend('Iesire aproximata', 'Iesire reala');

%%

inputData1_val = val.X{1};
inputData2_val = val.X{2};
outputData_val = val.Y;



[x1_val, x2_val] = meshgrid(inputData1_val, inputData2_val);

X1_val = x1_val(:);
X2_val = x2_val(:);

phi_val = ones(length(X1_val), N);

p = 1;

for i = 0:n
    for j = 0:(n-i)
        phi_val(:,p) = X1_val.^i .* X2_val.^j;
        p = p+1;
    end
end

y_aprox_val = phi_val * theta;

y_aprox_val = reshape(y_aprox_val, size(outputData_val));



mse_id = mean((outputData(:) - y_aprox(:)).^2);

mse_val = mean((outputData_val(:) - y_aprox_val(:)).^2);
disp(n);
fprintf('MSE identificare = %f\n', mse_id);
fprintf('MSE validare = %f\n', mse_val);

%%

figure
mesh(y_aprox_val); grid on
hold on
mesh(outputData_val); grid on
legend('Iesire aproximata', 'Iesire reala');
title('Validarea modelului');
