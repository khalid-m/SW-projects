function [rwArray] =cwArray2rwArray(cwArray)
a_ndims = ndims(cwArray);
a_size = size(cwArray);
new_ndims = ones(1,a_ndims);
for i=1:a_ndims
    new_ndims(i) = i;
end
new_ndims(1) = 2;
new_ndims(2) = 1;
disp(new_ndims);
transpose_cwArray = permute(cwArray,new_ndims);
rwArray = reshape(transpose_cwArray,a_size);
end