function [cwArray] = rwArray2cwArray(rwArray)
rw_size = size(rwArray);
rw_ndims = ndims(rwArray);
new_size = rw_size;
new_size(1) = rw_size(2);
new_size(2) = rw_size(1);
reshaped_rwArray = reshape(rwArray,new_size);
new_ndims = ones(1,rw_ndims);
for i=1:rw_ndims
    new_ndims(i) = i;
end
new_ndims(1) = 2;
new_ndims(2) = 1;
cwArray = permute(reshaped_rwArray,new_ndims);

end