clear all; close all; clc;
syms s

Ts = 0.1;
AMPLITUDE_OF_THE_STEP = 0.9; QUANTITY_SAMPLES = 300;


% MALHA ABERTA
k = 1; tau = 0.74225;
Gs = tf(k, [tau 1]);
Gz = transformStoZ(Gs, Ts);
[output, time] = equationOfTheDifference(Gz, AMPLITUDE_OF_THE_STEP, QUANTITY_SAMPLES, Ts);
plot(time, output, 'k', 'lineWidth', 2); grid on;
