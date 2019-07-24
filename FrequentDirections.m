% Outputs sketch of input matrix
% Author: Terence Lim
% Original paper/code by Liberty "Simple and Deterministric Matrix Sketching"

function [sketch, vout] = FrequentDirections(A, ell)
% input A is n rows x m columns; 
% output sketch B is l rows x m columns, vout is m x 1 first right eigenvector

rows = size(A, 1);
d = size(A, 2);
m = 2 * ell;

if (rows <= m)
  [U, S, Vt] = svd(A, 0);
  vout = Vt(:,1);
  sketch =  S * Vt';
  return
end

sketch = zeros(m, d);
nextZeroRow = 1;

for i=1:rows
  vector = A(i,:);      % append row
  
  if (nextZeroRow > m)  % rotate
    [U, S, Vt] = svd(sketch,0);  % economy SVD: sketch = U S V 
    disp(i);
    vout = Vt;
    s = diag(S);
    len = length(s);
    if (len >= ell)           % if rank is greater than ell, then shrink
      sShrunk = sqrt(s(1:ell).^2 - s(ell).^2);
      sketch(1:ell,:) = diag(sShrunk) * Vt(:,1:ell)';
      sketch((ell+1):end,:) = 0;
      nextZeroRow = ell + 1;     % maintain invariant that row l is zeros
    else                     % otherwise fewer than ell non-zero rows
      sketch(1:len,:) = S * Vt(:,1:len)';
      sketch((len+1):end,:) = 0;
      nextZeroRow = len + 1;
    end
  end
  
  sketch(nextZeroRow,:) = vector;    % append row
  nextZeroRow = nextZeroRow + 1;
end
sketch = sketch(1:ell, :);
return;
