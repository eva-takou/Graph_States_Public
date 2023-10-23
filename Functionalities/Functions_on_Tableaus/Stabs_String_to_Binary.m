function Stabs=Stabs_String_to_Binary(S)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Input should be a cell array of strings containing I,X,Y,Z.
%Each element of the cell array is a stabilizer generator.
%Output: The stabilizer representation in binary.

if ~iscell(S)
   error('Please provide the stabs as a cell of strings.') 

end

n=length(S);

Stabs = sparse(n,2*n);

for ii=1:n %loop through stabs

   for jj=1:length(S{ii})  %loop through opers

       if strcmpi(S{ii}(jj),'X')

           Stabs=Stabs+sparse(ii,jj,1,n,2*n);

       elseif strcmpi(S{ii}(jj),'Y')

           Stabs=Stabs+sparse(ii,jj,1,n,2*n);
           Stabs=Stabs+sparse(ii,jj+n,1,n,2*n);

       elseif strcmpi(S{ii}(jj),'Z')

           Stabs=Stabs+sparse(ii,jj+n,1,n,2*n);

       end


   end

end



end
