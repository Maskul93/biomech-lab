function m = magna(x)

% MAGNA Compute the norm (or magnitude) of X, a column N-by-M array


[r c] = size(x);
if r < c
    x = x';
end
m = zeros (length(x),1);

for i=1:length(x)
    m(i,1)=norm(x(i,:));
end
