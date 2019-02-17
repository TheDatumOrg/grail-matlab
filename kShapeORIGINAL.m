function [mem cent] = kShapeORIGINAL(A, K)

m=size(A, 1);
mem = ceil(K*rand(m, 1));
cent = zeros(K, size(A, 2));

for iter = 1:100
    %disp(iter);
    prev_mem = mem;
    
    for k = 1:K
        cent(k,:) = kshape_centroid(mem, A, k, cent(k,:));
    end
    
    D = zeros(m,K);
    
    for i = 1:m
        %x = A(i,:);
        for k = 1:K
            %y = cent(k,:);
            dist = 1-max( NCCcORIGINAL(A(i,:), cent(k,:) ) );
	    D(i,k) = dist;
        end
    end
    
    [val mem] = min(D,[],2);
    if norm(prev_mem-mem) == 0
        break;
    end
end

end

function centroid = kshape_centroid(mem, A, k, cur_center)
%Computes centroid
a = [];
for i=1:length(mem)
    if mem(i) == k
        if sum(cur_center) == 0
            opt_a = A(i,:);
        else
             [tmp tmps opt_a] = SBDORIGINAL(cur_center, A(i,:));
        end
        a = [a; opt_a];
    end
end

if size(a,1) == 0;
    centroid = zeros(1, size(A,2)); 
    return;
end;

[m, ncolumns]=size(a);
[Y mean2 std2] = zscore(a,[],2);
S = Y' * Y;
P = (eye(ncolumns) - 1 / ncolumns * ones(ncolumns));
M = P*S*P;

[V D] = qdwheig(M);

centroid = V(:,end);

finddistance1 = sqrt(sum((a(1,:) - centroid').^2));
finddistance2 = sqrt(sum((a(1,:) - (-centroid')).^2));

if (finddistance1<finddistance2)
    centroid = centroid;
else
    centroid = -centroid;
end

centroid = zscore(centroid);

end



function [Uout,eigvals] = qdwheig(H,normH,minlen,NS)
%QDWH-EIG    Eigendecomposition of symmetric matrix via QDWH.
%   [V,D] = QDWHEIG(A) computes the eigenvalues (the diagonal elements
%   of D) and an orthogonal matrix V of eigenvectors
%   of the symmetric matrix A. This function makes use of the function
%   QDWH that implements the QR-based dynamically weighted Halley
%   iteration for the polar decomposition.
%   [U,D] = QDWHEIG(A,normA,minlen,shift) includes the optional
%   input arguments
%      normA: norm(A,'fro'), which is used in the recursive calls.  
%     minlen: the matrix size at which to stop the recursions (default 1).
%         NS: Newton-Schulz postprocessing for better accuracy
%             1: do N-S (default), 0: don't N-S (slightly faster).
  
backtol = 10*eps/2; % Tolerance for relative backward error.
n = length(H);
%if nargin < 2 || isempty(normH); normH = norm(H,'fro'); end
%if nargin < 3 || isempty(minlen); minlen = 1; end
%if nargin < 4 || isempty(NS); NS = 1; end

normH = norm(H,'fro');
minlen = 1;
NS = 1;

[Uout,eigvals] = qdwheigrep(H,normH,minlen,backtol);

if NS
   Uout = 3/2*Uout-Uout*(Uout'*Uout)/2; % Newton-Schulz postprocessing.
end

eigvals = diag(sort(eigvals,'ascend'));
Uout = fliplr(Uout); % Order appropriately.

if nargout == 1; Uout = diag(eigvals); end

end
% Subfunctions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Uout,eigvals] = qdwheigrep(H,normH,minlen,backtol,a,b,shift)
% Internal recursion.
n = length(H);

% If already almost diagonal,  return trivial solution.
if norm(H-diag(diag(H)),'fro')/normH < backtol
    [eigvals IX] = sort(diag(H),'descend'); eigvals = eigvals';
    Uout = eye(n); Uout = Uout(:,IX);
    return
end

H = (H+H')/2;   % Needed for recursive calls, due to roundoff.

if nargin < 7 || isempty(shift)
   % Determine shift: approximation to median(eig(H)).
   shift = median(diag(H));
end

% Estimate a,b.
if nargin < 5 || isempty(a); a = normest(H-shift*eye(n),3e-1); end
if nargin < 6 || isempty(b); b = .9/condest(H-shift*eye(n)); end

% Compute polar decomposition via QDWH.
U = qdwh(H-shift*eye(n),a,b);

% Orthogonal projection matrix.
U = (U+eye(n))/2;

% Subspace iteration
[U1,U2] = subspaceit(U);
minoff = norm(U2'*H*U1,'fro')/normH; % backward error

if minoff > backtol
    % 'Second subspace iteration'.
    [U1,U2] = subspaceit(U,0,U1);
    minoff = norm(U2'*H*U1,'fro')/normH; % backward error
end

if minoff > backtol
    for irand = 1:2
        % Redo subspace iteration with randomization.
        [U1b,U2b] = subspaceit(U,1);
        minoff2 = norm(U2b'*H*U1b,'fro')/normH; % backward error
        if minoff > minoff2; U1 = U1b; U2 = U2b; end % take better case
    end
end

% One step done; further blocks.
eigvals = [];
if length(U1(1,:)) == 1
    eigvals = [eigvals U1'*H*U1];
end
if length(U2(1,:)) == 1
    eigvals = [eigvals U2'*H*U2];
end

eigvals1 = []; eigvals2 = [];    
if length(U1(1,:)) > minlen
    [Ua eigvals1] = qdwheigrep(U1'*H*U1,normH,minlen,backtol);
    U1 = U1*Ua;    
end

if length(U2(1,:)) > minlen
    [Ua eigvals2] = qdwheigrep(U2'*H*U2,normH,minlen,backtol);
    U2 = U2*Ua;    
end

Uout = [U1 U2];
% Collect eigvals
eigvals = [eigvals eigvals1 eigvals2];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [U0,U1] = subspaceit(U,use_rand,U1)
%SUBSPACEIT   Subspace iteration for computing invariant subspace.
%   [U0,U1] = SUBSPACEIT(U,use_rand,U1) computes an orthogonal basis U0 
%   for the column space of the square matrix U.
%   Normally one or two steps will yield convergence.
%   U1 is the orthogonal complement of U0.
%   Optional inputs:
%     use_rand: 1 to use randomization to form initial matrix (default 0).
%     U1: initial matrix (then use_rand becomes irrelevant).

n = length(U);
xsize = round(norm(U,'fro')^2); % (Accurate) estimate of norm of U0.

if nargin < 2; use_rand = 0; end

% Determine initial matrix.
if nargin >= 3 % Initial guess given.
    UU = U*U1;
elseif use_rand % Random initial guess.
    UU = U*randn(n,min(xsize+3,n));
else % Take large columns of U as initial guess.

% normcols = zeros(1,n);
% for ii = 1:n; normcols(ii) = norm(U(:,ii)); end;
% [normc,IX] = sort(normcols,'descend');
% UU = U(:,IX(1:min(xsize+3,n))); % Take columns of large norm.
UU = U(:,1:min(xsize+3,n));     % Take first columns.

end

[UU,R] = qr(UU,0); UU = U*UU;[UU,R] = qr(UU); % Subspace iteration.
U0 = UU(:,1:xsize); U1 = UU(:,xsize+1:end);
end

function [U,H,it] = qdwh(A,alpha,L,piv)
%QDWH   QR-based dynamically weighted Halley iteration for polar decomposition.
%   [U,H,it,res] = qdwh(A,alpha,L,PIV) computes the
%   polar decomposition A = U*H of a full rank M-by-N matrix A with 
%   M >=  N.   Optional arguments: ALPHA: an estimate for norm(A,2),
%   L: a lower bound for the smallest singular value of A, and 
%   PIV = 'rc' : column pivoting and row sorting,
%   PIV = 'c'           : column pivoting only,
%   PIV = ''    (default): no pivoting.
%   The third output argument IT is the number of iterations.

[m,n] = size(A);

tol1 = 10*eps/2; tol2 = 10*tol1; tol3 = tol1^(1/3);
if m == n && norm(A-A','fro')/norm(A,'fro') < tol2;
   symm = 1;
else
   symm = 0;
end

it = 0; 

if m < n, error('m >= n is required.'), end

if nargin < 2 || isempty(alpha) % Estimate for largest singular value of A.
   alpha = normest(A,0.1);
end

% Scale original matrix to form X0.
U = A/alpha; Uprev = U;

if nargin < 3 || isempty(L) % Estimate for smallest singular value of U.
   Y = U; if m > n, [Q,Y] = qr(U,0); end
   smin_est =  norm(Y,1)/condest(Y);  % Actually an upper bound for smin.
   L = smin_est/sqrt(n);   
end

if nargin < 4, piv = ''; end

col_piv = strfind(piv,'c');
row_sort = strfind(piv,'r');

if row_sort
   row_norms = sum(abs(U),2);
   [ignore,rind] = sort(row_norms,1,'descend');
   U = U(rind,:);
end

while norm(U-Uprev,'fro') > tol3 || it == 0 || abs(1-L) > tol1

      it = it + 1;
      Uprev = U;

      % Compute parameters L,a,b,c (second, equivalent way).
      L2 = L^2;
      dd = ( 4*(1-L2)/L2^2 )^(1/3);
      sqd = sqrt(1+dd);
      a = sqd + sqrt(8 - 4*dd + 8*(2-L2)/(L2*sqd))/2;
      a = real(a);
      b = (a-1)^2/4;
      c = a+b-1;
      % Update L.
      L = L*(a+b*L2)/(1+c*L2);

      if c > 100 % Use QR.
         B = [sqrt(c)*U; eye(n)];

          if col_piv
             [Q,R,E] = qr(B,0,'vector');
          else
             [Q,R] = qr(B,0); %E = 1:n;
          end

          Q1 = Q(1:m,:); Q2 = Q(m+1:end,:);
          U = b/c*U + (a-b/c)/sqrt(c)*Q1*Q2';

      else % Use Cholesky when U is well conditioned; faster.
          C = chol(c*(U'*U)+eye(n));
          % Utemp = (b/c)*U + (a-b/c)*(U/C)/C';
          % Next three lines are slightly faster.
          opts1.UT = true; opts1.TRANSA = true;
          opts2.UT = true; opts2.TRANSA = false;
          U = (b/c)*U + (a-b/c)*(linsolve(C,linsolve(C,U',opts1),opts2))';
    end
    if symm
       U = (U+U')/2;
    end
end
if row_sort
   U(rind,:) = U;
end

if nargout > 1
    H = U'*A; H = (H'+H)/2;
end


end


function cc_sequence = NCCcORIGINAL(x,y)

if isrow(x)
    x=x';
end
if isrow(y)
    y=y';
end

len = length(x);

fftlength = 2^nextpow2(2*len-1);
r = ifft( fft(x,fftlength) .* conj(fft(y,fftlength)) );

r = [r(end-len+2:end) ; r(1:len)];

cc_sequence = r./(norm(x)*norm(y));

end

function [dist shift yshift]= SBDORIGINAL(x,y)

if iscolumn(x)
    x=x';
end
if iscolumn(y)
    y=y';
end

X1=NCCcORIGINAL(x,y);

[m,d]=max(X1);

shift=d-max(length(x),length(y));
 
if shift < 0
        yshift = [y(-shift + 1:end) zeros(1, -shift)];
    else
        yshift = [zeros(1,shift) y(1:end-shift) ];
end

dist = 1-m;

end


