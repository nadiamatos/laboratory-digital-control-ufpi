function [output, time] = equationOfTheDifference(Gz, reference, quantitySamples, timeSample)
  %{
  This function is used for to get difference equation. Just works
  for denominator with degree 1.
  %}

  [numerator, denominator] = tfdata(Gz);
  beta = numerator{1}(1, 2)/denominator{1}(1, 1)
  gamma = -1*denominator{1}(1, 2)/denominator{1}(1, 1)

  quantitySamples = quantitySamples + 1;
  control = reference*ones(1, quantitySamples);
  output = zeros(1, quantitySamples);
  time = zeros(1, quantitySamples);

  for k = 1 : quantitySamples-1
    output(k+1) = beta*control(k) + gamma*output(k);
    time(k+1) = k*timeSample;
  end

end
