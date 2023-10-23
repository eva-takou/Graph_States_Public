function [Q_transf,flag]=LC_check(G1,G2)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%
%Solve the problem Ax=0, where x is the vector:
%x = [c_1 ... c_n a_1 ... a_n d_1 ... d_n b_1 ... b_n]^T
%given the constraints a_i d_i + b_i c_i = 1 (i.e., det[Q_i]=1)
%--------------------------------------------------------------------------
%Inputs: Adjacency matrices of G1 and G2 graphs
%Output: Q_transf: The solution to the LC equivalence test if it exists.
%        flag: true or false
%
%This method is from Bouchet's paper "Recognizing locally equivalent
%graphs", Discrete Mathematics 114, 75-86 (1993).
%--------------------------------------------------------------------------

[Anew,free_variables] = Construct_LC_matrix(G1,G2);

NullVecMatrix = GF2_Null_Space(Anew,free_variables);
sols          = Constrained_NullSpace(NullVecMatrix);

if isempty(sols)
   
    Q_transf=[];
    flag=false;
    return
    
end

Q_i = Reconstruct_Qis(sols);

%Each of the sols corresponds to a series of LCs because we know that we 
%have one Q_i which is supposed to act on the ith qubit.

for l=1:length(Q_i)
    for jj=1:length(Q_i{l})
    strSols{l}{jj} = Recognize_Qi_s(Q_i{l}{jj});
    end
end

%Inspect that we recover the 2nd adjacency matrix:
n  = size(G1,2);
Sx = speye(n);

Stabs1 = [G1; Sx]; %2n x n matrix
Stabs2 = [G2; Sx];
P      = [sparse(n,n) speye(n);...
          speye(n)    sparse(n,n)];

%Need to extend each Qi's in total space

%First row of Q tells us how the Sz part changes
%Second row of Q tells us how the Sx part changes

%[a b][Sz]    -> [aSz+bSx]
%[c d][Sx]    -> [cSz+dSx]

for jj=1:length(Q_i)

    current_Q = Q_i{jj};
    Q = sparse(2*n,2*n);

    for qubit=1:length(current_Q)

        q = current_Q{qubit};

        for entry_i = 1:2

            for entry_j = 1:2

                Q = Q + sparse(qubit+n*(entry_i-1), qubit+n*(entry_j-1) ,q(entry_i,entry_j),2*n,2*n);

            end 
        end

        Q_transf{jj} = Q;

    end

    %LC equivalence condition up to basis change:
    test_cond = mod(Stabs1' * Q' * P * Stabs2,2);

    if all(all(test_cond==sparse(n,n)))

    else
        error('Wrong Q.')
    end

end


flag=true;


end
