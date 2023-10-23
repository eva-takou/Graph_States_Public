function Z = MY_setdiff(X,Y)
%from: https://www.mathworks.com/matlabcentral/answers/53796-speed-up-intersect-setdiff-functions
if ~isempty(X)&&~isempty(Y)
  check = false(1, max(max(X), max(Y)));
  check(X) = true;
  check(Y) = false;
  Z = X(check(X));  
else
  Z = X;
end