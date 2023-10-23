function NullVecMatrix = GF2_Null_Space(Anew,free_variables)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Anew is the matrix after Gaussian elimination (& we have performed back-substitution).
%The rows of Anew where we zero-out the pivots are the null-vectors
%x = [c_1 ... c_n a_1 ... a_n d_1 ... d_n b_1 ... b_n]^T

%Output: The unconstrained nullspace (null vectors) in matrix form. Each
%column is a vector of the nullspace of matrix Anew. The NullVecMatrix is a
%4n x length(free_variables) matrix.
 
rowSz = size(Anew,1); %n^2
n     = sqrt(rowSz);

%For each row, read column-wise to collect in terms of which free
%vars each coeff is expressed as

for rows=1:n^2
 
    pivot  = find(Anew(rows,:),1);
 
    if isempty(intersect(pivot,free_variables)) && ~isempty(pivot)
    
        locs       = find(Anew(rows,:));
        locs       = setxor(locs,pivot);
        var{pivot} = locs;
 
    end

end

for jj=1:length(free_variables)

    var{free_variables(jj)} = free_variables(jj);
    
end

%read all vars and construct a 4n x length(free_variables) matrix:
NullVecMatrix = sparse(4*n,length(free_variables));

for jj=1:length(var)

 for kk=1:length(free_variables)

     this_var = free_variables(kk);

     if ~isempty(intersect(this_var,var{jj}))

        NullVecMatrix = NullVecMatrix+sparse(jj,kk,1,4*n,length(free_variables));

     end

 end

end




end
