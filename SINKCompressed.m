function sim = SINKCompressed(FFTx,FFTy,gamma, len)
% Shift INvariant Kernel

sim = SumExpNCCc(FFTx,FFTy,gamma,len);

end

function sim = SumExpNCCc(FFTx,FFTy,gamma,len)

sim = sum(exp(gamma*NCCcFourier(FFTx,FFTy,len)));

end