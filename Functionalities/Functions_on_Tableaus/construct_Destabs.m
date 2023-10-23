function D=construct_Destabs(S)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to generate the destabilizer group.
%Input:  S: The stabilizer nx2n array in binary & sparse form.
%Output: D: The nx2n destabilizer array in binary & sparse form.  

[n,~]=size(S);

Sx = S(:,1:n); Sz = S(:,n+1:2*n);  D = sparse(n,2*n);

for ii=1:n

    tempX = Sx(ii,:); tempZ = Sz(ii,:); %Getting the i-th qubit of the ith stabilizer

    if tempX(ii)==1

        D = D + sparse(ii,ii+n,1,n,2*n); %make it Z_i

    elseif tempZ(ii)==1

        D = D + sparse(ii,ii,1,n,2*n);   %make it X_i

    else %If we dont do anything, then the destab row will be all identities
         %If we put X or Z on one of the other qubits will  destabs commute?                

         error('Do not have the capability to produce destabilizers for this case.')
         
    end




end




end
