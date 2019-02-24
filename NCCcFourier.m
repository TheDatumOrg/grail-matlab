function cc_sequence = NCCcFourier(FFTx,FFTy,len)
% len is the original time series length
% fftlength is the new power of 2 length
% FFTx is the vector with fourier coeffs after compression 
% FFTy is the vector with fourier coeffs after compression

r = real(ifft( FFTx .* conj(FFTy)));

r = [r(:,end-len+2:end) , r(:,1:len)];

cc_sequence = r./len;

end