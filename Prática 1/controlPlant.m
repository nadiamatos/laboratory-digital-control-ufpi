%{
 Disciplina: Controle Digital 2019
 Data: 13 de Abril de 2019
 Professor: Otacilio da Mota Almeida

 Adaptado: Nadia Raquel Matos Oliveira
 email: nadiamatos.18@gmail.com
%}

clc; clear; close all;

% CONSTANTS FOR EVERY CODE!!!
QUANTITY_SAMPLES = 300; TIME_SAMPLE = 0.1; CODE = 1;
AMPLITUTE_REFERENCE = 15; % Change value of the pwm!!

% VARIABLES FOR EVERY CODE!!!
pwm = AMPLITUTE_REFERENCE;
output = zeros(1, QUANTITY_SAMPLES);
erro = zeros(1, QUANTITY_SAMPLES);
tempo = zeros(1, QUANTITY_SAMPLES);
reference = AMPLITUTE_REFERENCE*ones(1, QUANTITY_SAMPLES);

% ########################################################################
% MAIN LOOP - THIS PART CALLS EVERYTHING!!!

serial = setupSerial();

% Coletando dados
for k = 1 : QUANTITY_SAMPLES
  tt = clock;
  cleanBufferSerial(serial);
  sendCommandsSerial(serial, CODE);
  sendCommandsSerial(serial, pwm);
  sendCommandsSerial(serial, 10);
  output(k) = receiveDataSerial(serial);
  %tirar o comentario das duas linhas abaixo, para MF.
  %pwm = reference(k) - output(k); % corresponde a um erro que servir� de entrada!!
  %pwm = testSaturationOfThePlant(pwm);
  tempo = k*TIME_SAMPLE;
  while etime(clock, tt) < Ts
    % nada dever ser feito enquanto o tempo de amostragem nao terminar!!
  end
end

% Plotando os dados coletados
figure;
plot(tempo, output, 'LineWidth', 2); hold on;
plot(tempo, reference, 'LineWidth', 2); hold on;
title('Grafico da Velocidade'); xlabel('Tempo (s)'); ylabel('Velocidade (RPS)');

setupPlant(s)
% #########################################################################


% *************************************************************************
function pwm = testSaturationOfThePlant(pwm)
  MAXIMO = 100; MINIMO = 0;
  if (pwm > MAXIMO)
    pwm = MAXIMO;
  elseif (pwm < MINIMO)
    pwm = MINIMO;
  end
end

function [serial] = setupSerial()
  [isSerialAvailable, serialsAvailable] = findSerialAvailable();
  if (isSerialAvailable)
    serial = connectSerial(isSerialAvailable, serialsAvailable);
    openSerial(serial);
    setupPlant(serial);
    tt = clock;
    while etime(clock, tt) < 3
      % loop para nao fazer nada!! nao retirar!!
    end
  end
end

function [isSerialAvailable, serialsAvailable] = findSerialAvailable()
  % Function for to find COM ports available and connected to computer.
  if (~isempty(instrfindall))
    fclose(instrfindall);
  end
  serialsAvailable = seriallist();
  isSerialAvailable = true;
  if (isempty(serialsAvailable))
    isSerialAvailable = false;
    error('NENHUMA SERIAL ENCONTRADA PARA REALIZAR CONEXAO!!');
  end
end

function s = connectSerial(isSerialAvailable, serialsAvailable)
  % Function for to start COM port connected to computer.

  %%% TRATAR O CODIGO PARA CAPTURAR A PORTA COM DISPONIVEL!!!
  %%% S� � POSSIVEL FAZER COM A PLANTA

  BAUD_RATE = 19200;
  s = serial('COM9', 'BaudRate', BAUD_RATE);
  s.terminator = 'LF';
end

function closeSerial(s)
  fclose(s);
  disp('Serial fechada.');
end

function openSerial(s)
  % Function for to open COM port connected to computer.
  try
    fopen(s);
  catch
    error('NAO FOI POSSIVEL ABRIR A PORTA COM');
    closeSerial(instrfindall)
  end
end

function setupPlant(s)
  % zerar PWM % Canal pwm ventilador
  fprintf(s, sprintf('2'));
  % Canal pwm resistor
  fprintf(s, sprintf('3'));
end

function cleanBufferSerial(s)
  flushinput(s);
  flushoutput(s);
end

function sendCommandsSerial(s, command)
  fwrite(s, command, 'uint8');
end

function answer = receiveDataSerial(s)
  Ts = TIME_SAMPLE;
  answer = fread(s, 2);
  answer = double(bitor(bitshift(uint16(answer(1)),8),uint16(answer(2))))/(7*Ts);
end
