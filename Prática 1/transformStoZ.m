%{
  This script is for to calculate Z Transform using um transfer function
  in Laplace. For this, we use the method present in the book ...
%}


function Gz = transformStoZ(functionPlant, timeSample)

  % Based in the pag 140 of the book.
  syms s a z
  Gz = 0;

  [numerator, denominator] = tfdata(functionPlant);
  functionPlant = (poly2sym(cell2mat(numerator), s)/poly2sym(cell2mat(denominator), s));
  plant = (1/s)*functionPlant;
  [numerator, denominator] = numden(plant);
  xn = calculateRoots(denominator);
  derivateD = expand(diff(denominator, s));
  polynomialAuxiliar = simplifyFraction(1/(1 - exp(a*timeSample)*(z^-1)));

  for i = 1 : size(xn, 1)
    valueOfTheNumerator = double(subsValueInExpression(numerator, s, xn(i)));
    valueOfTheDerivateD = subsValueInExpression(derivateD, s, xn(i));
    valueOfThePolynomialAuxiliar = subs(polynomialAuxiliar, a, xn(i));
    Gz = Gz + simplifyFraction((valueOfTheNumerator/valueOfTheDerivateD)*valueOfThePolynomialAuxiliar);
  end

  Gz = (1 - z^-1)*Gz;
  [numerator, denominator] = numden(Gz);
  Gz = tf(sym2poly(numerator), sym2poly(denominator), timeSample);
end

function valueEnd = subsValueInExpression(expression, variable, value)
  valueEnd = subs(expression, variable, value);
  if (valueEnd == 0)
    valueEnd = 1;
  end
end

function roots = calculateRoots(expression)
  roots = double(solve(expression == 0));
  if (all(roots == 0))
    roots = 0;
  end
end
