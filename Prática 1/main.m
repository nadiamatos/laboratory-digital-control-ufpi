% CODIGO DESENVOLVIDO: main.m
% Este codigo e' o principal e chama todos os outros codigos disponiveis neste apendice.

clear all; close all; clc;
syms s

Ts = 0.1;
AMPLITUDE_OF_THE_STEP = 90; QUANTITY_SAMPLES = 300;

% fig coletado em laboratorio a partir de dados fornecidos pela planta
fig = openfig('1_c_90.fig');

% MALHA ABERTA
k = 1; tau = 0.74225;
Gs = tf(k, [tau 1]);
Gz = transformStoZ(Gs, Ts);
[output, time] = equationOfTheDifference(Gz, AMPLITUDE_OF_THE_STEP, QUANTITY_SAMPLES, Ts);

% calculando o erro entre o que foi fornecido pela planta e o que foi estimado pelo algoritmo desenvolvido.
erro = fig.Children.Children(2).YData - output;

hold on;
plot(time, output, 'k', 'lineWidth', 2);
hold on;
plot(time, erro, 'c', 'lineWidth', 2);
grid on; title('Grafico da Velocidade');
xlabel('Tempo (s)'); ylabel('Velocidade (RPS)');
