function [Tab,outcome]=Measure_single_qubit(Tab,qubit,basis)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to measure a qubit from the tableau.
%Input: Tab: The tableau
%       qubit: the qubit to be measured
%       basis: 'X', or 'Y' or 'Z' basis measurement
%Output: Tab: The updated tableau
%        outcome: The outcome (0 or 1) after the measurement.
%This script follows the methods developed by Scott Aaronson and Daniel
%Gottesman, Phys. Rev. A 70, 052328 (2004)
%



n=(size(Tab,2)-1)/2;

switch basis

    case 'X'

        Tab = Had_Gate(Tab,qubit,n);

    case 'Y'
        %Y = -(H*P)'*Z*(H*P)

        Tab = Phase_Gate(Tab,qubit,n);
        Tab = Had_Gate(Tab,qubit,n);

end
  
            
[l,~]=size(Tab);
n=(l-1)/2;


%Apply the Aaronson and Gottesman algorithm

p=find(Tab(n+1:2*n,qubit)); %find if there is nnz X part for that qubit
p=p+n;

%=== Random outcome ===============================

if ~isempty(p)
    disp('Outcome: Random')

    if length(p)==1
        q=p;
    elseif length(p)>1
        q=min(p);

    end

    j_indx = find(Tab(:,qubit)); %For all other rows (j \neq p) find when we have x=1
    j_indx = setdiff(j_indx,q);           

    for I=1:length(j_indx)

       Tab = rowsum(Tab,j_indx(I),q); 

    end

   Tab(q-n,:)      = Tab(q,:);  % Set the (p-n)^th row equal to p-th row
   Tab(q,:)        = zeros(1,2*n+1);    % Set the p-th row to be identically 0.
   Tab(q,qubit+n)  = 1;                 % The p-th row will have z=1 if we have Z measurement.
   outcome         = randi([0,1]);      % Flip a coin for the phase, i.e. whether we got + or - outcome:
   Tab(q,end)      = mod(outcome+Tab(q,end),2);           %update the phase

   disp(['Outcome was: ',num2str(outcome)])

% Do rowsum operations to remove the operator found
% in location of qubit from the remaining stabs/destabs:

    %do rowsum on stabs
    temp=Tab;
    for ll=1:n
        if ll+n~=q

            if Tab(ll+n,qubit+n)==1

                Tab = rowsum(Tab,ll+n,q);
            end
        end
    end            

    %do rowsum on destabs: is this correct?
    for ll=1:n

        if ll~=q-n
            if temp(ll+n,qubit+n)==1
                Tab = rowsum(Tab,q-n,ll);
            end
        end
    end            

else %outcome is determinate
    disp('Outcome: determinate')
    Tab(end,:)=sparse(1,2*n+1);

    for jj=1:n %For jj=1,...,n call rowsum(2n+1,jj+n) if xj=1

        if Tab(jj,qubit)==1

           Tab=rowsum(Tab,2*n+1,jj+n);

        end

    end                

    outcome=full(Tab(2*n+1,end));
    disp(['Outcome was',num2str(outcome)])

end

%I think for X/Y measurement we should rotate again.

switch basis

    case 'X'

        Tab = Had_Gate(Tab,qubit,n);

    case 'Y'
        %Y = -(H*P)'*Z*(H*P)

        Tab = Phase_Gate(Tab,qubit,n);
        Tab = Had_Gate(Tab,qubit,n);

end



end


