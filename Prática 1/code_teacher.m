%Disciplina: Controle Digital 2019
%Data: 09 de maio de 2019
%Professor: Otac�lio da Mota Almeida

%Limpar o Workspace - INICIO
   clc;
   %Deletar todas as vari�veis no Workspace
   clear;
   %Fechar todas as Janelas
   close all;
%Limpar o Workspace - FIM

%criar objeto porta serial - INICIO
  %Verificar em Gerenciador de Dispositivos
  s = serial('COM9', 'BaudRate', 19200);
  %Ajustar o caractere final para '\n'
  s.terminator = 'LF';
%criar objeto porta serial - FIM

%Verificar as portas abertas pelo MATLAB - INICIO
   out = instrfind(s);
   if(out.status == 'closed')
      fclose(instrfind);
      fclose(instrfindall);
      %Abrir a comunica��o Serial
      fopen(s);
   end
  %Verificar as portas abertas pelo MATLAB - FIM
 Codigo = '1';
 % Codigo=0 para a Temperatura do resistor
 % Codigo=1 para Velocidade do Cooler

%Ajustar o per�odo de amostragem
Ts = 0.1;

%Quantidade de amostras
Qde_amostras = 300;


%zerar PWM
%Canal pwm ventilador
fprintf(s,  sprintf( '2' ));
%Canal pwm resistor
fprintf(s,  sprintf( '3' ));

%delay 'Diferente' com etime() (mais preciso que pause())
tt = clock;
while etime(clock, tt) < 3
%n�o fazer nada enquanto o n�o passar de 5 segundos
end

%INJETA UM DEGRAU DE TENS�O

REF = 15; % Refer�ncia 80% do PWM
pwm = REF;
figure(1);
for k=1:Qde_amostras
    tt = clock;
    %Zera buffer da serial
    flushinput(s);
    flushoutput(s);

    fwrite(s,Codigo,'uint8'); % Codigo=1 para Velocidade do Cooler
    fwrite(s,pwm,'uint8'); %Envia valor de PWM para Motor
    fwrite(s,10,'uint8');  %C�digo quebra de linha � necess�rio indicando que finalizou o dado
    resposta = fread(s,2); %

  saida(k) = double(bitor(bitshift(uint16(resposta(1)),8),uint16(resposta(2))))/(7*Ts);
   ref(k) = REF;
   erro(k)=ref(k)-saida(k);
   pwm=erro(k);
      %TESTE DE SATURA��O
    if(pwm > 100)
        pwm = 100;
    else
        if(pwm<0)
           pwm =0;
        end
    end
   % FIM DO TESTE DE SATURA��O

    %DELAY
    while etime(clock, tt) < Ts
    %n�o fazer nada enquanto o tempo de amostragem n�o terminar
    end
 end



Tempo = [1:Qde_amostras]*Ts;
plot(Tempo,saida,'LineWidth',2);
hold on;

plot(Tempo,ref,'r','LineWidth',2);
drawnow
grid on;

if(Codigo == '1')
   %Saida de Velocidade
   title('Gr�fico da Velocidate'); xlabel('Tempo (s)'); ylabel('Velocidade (RPS)');
else
   %Saida de temperatura
   title('Gr�fico da Temperatura'); xlabel('Tempo (s)'); ylabel('Tens�o (mV)');
end

%zerar PWM
%Canal pwm ventilador
fprintf(s,  sprintf( '2' ));
%Canal pwm resistor
fprintf(s,  sprintf( '3' ));


fclose(s);
