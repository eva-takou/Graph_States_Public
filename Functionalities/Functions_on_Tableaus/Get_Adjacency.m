function [Gamma,store_opers]=Get_Adjacency(varargin) %(Tab)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to obtain the adjacency matrix from a Tableau.
%Input: Tableau and if option (true or false) to store or not the operations that transform
%       the Tableau in canonical form.
%Output: Gamma: Adjacency matrix
%        store_opers: The operations that transform the Sz part of the
%        tableau to the canonical form.

Tab = varargin{1};
cnt = 0;

if nargin>1
    
    flag_opers = true;
    
else
    
    flag_opers  = false;
    store_opers = [];
end

n  = size(Tab,2);
n  = (n-1)/2;
Sx = Tab(n+1:2*n,1:n);
Sz = Tab(n+1:2*n,n+1:2*n);

if all(all(Sx==speye(n)))
   
    Gamma=Sz;
    
    for ll=1:size(Gamma,1)

        if Gamma(ll,ll)==1 
            %There is a Y operator, which can be removed with a phase gate.
            %disp('There is a Y operator, I will <<perform>> a phase gate.')

            if flag_opers

                cnt=cnt+1;
                store_opers(cnt).qubit=ll;
                store_opers(cnt).gate='P';

            end

            Gamma(ll,ll)=0;

        end
    end
    
    mustBeValidAdjacency(Gamma)
    return
    
end

for qubit=1:n
    
    locs  = find(Tab(n+1:2*n,qubit)); %Check the columns to see if we have X
    
    if isempty(locs) || isempty(locs(locs>=qubit)) %If there is no X, do a Had

       Tab = Clifford_Gate(Tab,qubit,'H'); 
    
       if flag_opers
           
           cnt=cnt+1;
           store_opers(cnt).qubit=qubit;
           store_opers(cnt).gate='H';
           
       end
       
    end
    
    locs = find(Tab(n+1:2*n,qubit)); %Check again where the 1s appeared:
    locs = locs(locs>=qubit);
    
    if locs(1)~=qubit %SWAP stabs 
        
        Tab = SWAP_rows(Tab,qubit+n,locs(1)+n);
        
    end
    
    locs = find(Tab(n+1:2*n,qubit));
    locs = locs(locs>qubit);
    
    for jj=1:length(locs) %Remove Xs appearing below the diagonal entry
       
        %Tab = rowsum(Tab,locs(jj)+n,qubit+n);
        Tab = rowsum(Tab,locs(jj)+n,qubit+n);
    end
    
    
end

for qubit=1:n %Back-substitution
    
   locs = find(Tab(n+1:2*n,qubit));
   locs = setxor(locs,qubit); %remove the diagonal position where we want to keep the X
   
   for kk=1:length(locs)
       
       %Tab = rowsum(Tab,locs(kk)+n,qubit+n);
       Tab = rowsum(Tab,locs(kk)+n,qubit+n);
       
   end
   
end

Sx = Tab(n+1:2*n,1:n);
Sz = Tab(n+1:2*n,n+1:2*n);


if ~all(all(speye(n)==Sx))
    error('At the end of Gauss elimination, the Sx part of the Tableau is not identity')
else
    Gamma=Sz;
end


for ll=1:size(Gamma,1)

    if Gamma(ll,ll)==1 && Sx(ll,ll)==1
        %There is a Y operator, which can be removed with a phase gate.
        %disp('There is a Y operator, I will <<perform>> a phase gate.')
        
        if flag_opers
           
            cnt=cnt+1;
            store_opers(cnt).qubit=ll;
            store_opers(cnt).gate='P';
            
        end
        
        Gamma(ll,ll)=0;

    elseif Gamma(ll,ll)==1 && ~Sx(ll,ll)==1

        error('Error in adjacency matrix, graph is not simple (detected self loop).')

    end
end

mustBeValidAdjacency(Gamma)



end