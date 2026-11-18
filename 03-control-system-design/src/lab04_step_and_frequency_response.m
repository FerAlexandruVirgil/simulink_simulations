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

t = 0:0.1:50;
regulatoare = {Hc1, Hc2, Hc3, Hc4};
nume = {'Hc1 = 2', 'Hc2 = 2/s', 'Hc3 = 10/(s+10)', 'Hc4 = 2/s^2'};
for k = 1:numel(regulatoare)
    Hc = regulatoare{k};
    Hd = series(Hc, Hf);
    Ho = feedback(Hd, 1);
    if ~isstable(Ho)
        fprintf('%s: sistemul in bucla inchisa este instabil\n', nume{k});
    end

    figure;
    subplot(2,2,1); step(Ho); title(['treapta, ' nume{k}]);
    subplot(2,2,2); lsim(Ho,t,t); title('rampa');
    subplot(2,2,3); lsim(Ho, t.^2,t); title('parabola');
    subplot(2,2,4); bode(Hd); title('bucla deschisa');
end

