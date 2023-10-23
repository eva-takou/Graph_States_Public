function [Anew,free_variables]=Construct_LC_matrix(G1,G2)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Construct the LC matrix according to Bouchet's paper. The final goal is to
%solve the problem Ax=0. This script constructs the A matrix.
%A is a n^2 (# of equations) x 4n (# of unknowns) matrix.

%Input: 2 adjacency matrices

%We want to construct the matrix A:
%alpha_1^{11} ... alpha_n^{11} beta_1^{11} ... beta_n^{11} gamma_1^{11} ... gamma_n^{11} delta_1{11} ... delta_n^{11}
%     .
%     .
%     .
%%alpha_1^{nn} ... alpha_n^{nn} beta_1^{nn} ... beta_n^{nn} gamma_1^{nn} ... gamma_n^{nn} delta_1{nn} ... delta_n^{nn}

%alpha_i^{vw}=1 if G1(i,v)=1 & G2(i,w)=1
%beta_i^{vw} =1 if G1(i,v)=1 & i=w
%gamma_i^{vw}=1 if i=v and G2(i,w)=1
%delta_i^{vw}=1 if i=v=w

n     = size(G1,1); %number of qubits
ntest = size(G2,1);

if n~=ntest
   error('Adjacency matrices do not have equal number of qubits.') 
end            

%===================== Construct the A matrix =============================

A = sparse(n^2,4*n);

for ii=1:n

    for v=1:n

        for w=1:n

            row       = w+n*(v-1); %goes till n^2
            col_alpha = ii;
            col_beta  = ii+n;
            col_gamma = ii+2*n;
            col_delta = ii+3*n;

            if G1(ii,v)==1 && G2(ii,w)==1

               alpha_i_vw = 1;

            else

               alpha_i_vw = 0;

            end

            if G1(ii,v)==1 && ii==w

                beta_i_vw = 1;

            else

                beta_i_vw = 0;

            end

            if G2(ii,w)==1 && ii==v

                gamma_i_vw = 1;

            else

                gamma_i_vw = 0;

            end

            if ii==v && v==w

                delta_i_vw = 1;

            else

                delta_i_vw = 0;
            end

            A = A + sparse(row,col_alpha,alpha_i_vw,n^2,4*n);
            A = A + sparse(row,col_beta,beta_i_vw,n^2,4*n);
            A = A + sparse(row,col_gamma,gamma_i_vw,n^2,4*n);
            A = A + sparse(row,col_delta,delta_i_vw,n^2,4*n);

        end
    end


end

%============= Do Gaussian elimination ====================================

Anew = Gauss_elim_GF2(A); 

%Get the non-free variables:

cnt=0;
for row=1:n^2

    %Could be non-existing pivot if an entire row is 0
    
    possible_pivot = find(Anew(row,:),1); %Find the first non-zero element which is the pivot

    if ~isempty(possible_pivot)
       
       cnt                = cnt+1; 
       rows_w_pivots(cnt) = row;
       pivots(cnt)        = possible_pivot; %pivots range from 1 till 4*n. These are the non-free variables (columns of Anew correspond to a_j,b_j,c_j,d_j)

    end

end

%=Express all non-free variables in terms of free ones (back-substitution)=

for ll=length(pivots):-1:1

    row_locs = find(Anew(:,pivots(ll)));
    row_locs = setxor(row_locs,rows_w_pivots(ll));

    if length(row_locs)>=1 %back-substitution

        for jj=1:length(row_locs)
            Anew = bitxor_rows(Anew,row_locs(jj),rows_w_pivots(ll));
        end
    end

end

free_variables = setxor(1:4*n,pivots);




end

