function DSFourier = DatasetToFourier(DS, FourierEnergy, DatasetPercentile)
% zscore and zeropad time-series to 2x length and replace Data, Train and
%   Test with dft coefficients.  Call after ds = LoadUCRDatasets
%   Optionally fills .F with number of coeffs needed for energy>eta/s

DS.Train = DS.Train ./ norm(DS.Train(1,:));
DS.Test = DS.Test ./ norm(DS.Test(1,:));
DS.Data = DS.Data ./ norm(DS.Data(1,:));

DSFourier = DS;


% Compute DFT of the data
DSFourier.len = length(DS.Data(1,:));
DSFourier.fftlength = 2^nextpow2(2*DSFourier.len-1);
%TrainTemp = [zeros(DS.TrainInstancesCount,floor((DSFourier.fftlength-DSFourier.len)/2)),DS.Train,zeros(DS.TrainInstancesCount,ceil((DSFourier.fftlength-DSFourier.len)/2))];
%TestTemp = [zeros(DS.TestInstancesCount,floor((DSFourier.fftlength-DSFourier.len)/2)),DS.Test,zeros(DS.TestInstancesCount,ceil((DSFourier.fftlength-DSFourier.len)/2))];
%DSFourier.TrainFourier = fft(TrainTemp,[],2);
%DSFourier.TestFourier = fft(TestTemp,[],2);
DSFourier.fftlength = 2^nextpow2(2*DSFourier.len-1);
DSFourier.TrainFourier = fft(DS.Train,DSFourier.fftlength,2);
DSFourier.TestFourier = fft(DS.Test,DSFourier.fftlength,2);
DSFourier.DataFourier = [DSFourier.TrainFourier; DSFourier.TestFourier];

% Preserve Percent of Energy in Fourier space of each time series

E = cumsum(abs(DSFourier.DataFourier) .^ 2, 2);    % Energy is squared abs
E = bsxfun(@rdivide, E, E(:, end));
DSFourier.DataCoeffsUntilEnergy = zeros(size(DSFourier.DataFourier,1),length(FourierEnergy));
for i = 1:size(DSFourier.DataCoeffsUntilEnergy,1)
  for j = 1:size(DSFourier.DataCoeffsUntilEnergy, 2)
    % find first coefficient that exceeds eta/2 - due to symmetry as we
    % give the full DFT and not half of it
    DSFourier.DataCoeffsUntilEnergy(i, j) = find(E(i, :) >= FourierEnergy(j)/2, 1);   
  end
end

% Keep number of coefficients across all time series so that you preserve
% at least FourierEnergy for DatasetPercentile specified

DSFourier.NumCoeffs = ceil(prctile(DSFourier.DataCoeffsUntilEnergy,DatasetPercentile));

DSFourier.TrainFourierCompressed = leading_fourier(DSFourier.TrainFourier, DSFourier.NumCoeffs);
DSFourier.TestFourierCompressed = leading_fourier(DSFourier.TestFourier, DSFourier.NumCoeffs);
DSFourier.DataFourierCompressed = [DSFourier.TrainFourierCompressed; DSFourier.TestFourierCompressed];

end

function x = leading_fourier(x, k)
% leading_fourier(x,k) returns leading k and trailing k-1 (real is symmetric) coeffs
%   by zeroing out middle window and renormalizing
m = floor(size(x, 2) / 2) + 1;
x(:, (k+1):(m - 1 + m - k)) = 0;
end