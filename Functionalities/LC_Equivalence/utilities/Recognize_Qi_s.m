function strQ = Recognize_Qi_s(Qi)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Transformation rules of [Sz|Sx]^T matrix under single Clifford gate.

QP = sparse([1 1 ; 0 1]);
QH = sparse([0 1 ; 1 0]);

%The Q of X,Y,Z operators is just identity.

QPH  = QP*QH;
QHP  = QH*QP;
QHPH = QH*QP*QH;
QPHP = QP*QH*QP;

cond_eq =@(A,B) all(all(A==B));


if cond_eq(Qi,QH)

    strQ = 'H';

elseif cond_eq(Qi,QP)
    strQ = 'P';


elseif cond_eq(Qi,QPH) 

    strQ = 'PH';

elseif cond_eq(Qi,QHP) 

    strQ = 'HP';

elseif cond_eq(Qi,QHPH) 

    strQ = 'HPH';

elseif cond_eq(Qi,QPHP)  

    strQ = 'PHP';

elseif cond_eq(Qi,speye(2)) %Can be any pauli \sigma_0={1,X,Y,Z}.
    
    strQ = 'X'; %just pick an X
    
else

    error('Unknown Q.')

end



end
