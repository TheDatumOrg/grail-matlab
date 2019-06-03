function sim = SINKCompressed(x,y, gamma, k)
% Shift INvariant Kernel

sim = SumExpNCCcCompressed(x,y,gamma,k)/sqrt(SumExpNCCcCompressed(x,x,gamma,k) * SumExpNCCcCompressed(y,y,gamma,k));

end

function sim = SumExpNCCcCompressed(x,y,gamma,k)

sim = sum(exp(gamma*NCCcCompressed(x,y,k)));

end