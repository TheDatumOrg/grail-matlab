function cc_sequence = NCCcCompressed(x, y, k)
% x is a time series
% y is a time series
% k is the # of Fourier coefficients to keep

if isrow(x)
    x=x';
end
if isrow(y)
    y=y';
end

len = max(length(x),length(y));

fftlength = 2^nextpow2(2*len-1);

FFTx = leading_fourier(fft(x',fftlength),k);
FFTy = leading_fourier(fft(y',fftlength),k);

r = ifft( FFTx.' .* conj(FFTy.') );

r = [r(end-len+2:end) ; r(1:len)];

cc_sequence = r./(norm(x)*norm(y));

end

function x = leading_fourier(x, k)
% leading_fourier(x,k) returns leading k and trailing k-1 (real is symmetric) coeffs
%   by zeroing out middle window and renormalizing
m = floor(size(x, 2) / 2) + 1;
x((k+1):(m - 1 + m - k)) = 0;
end