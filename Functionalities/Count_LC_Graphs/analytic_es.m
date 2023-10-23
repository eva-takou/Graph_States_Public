function e=analytic_es(n,graphtype)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%



switch graphtype
    
    
    case 'Pn' %OK
        
        if n==1

            e=2;
        
        elseif n==2
            
            e = 6;
            
        elseif n>2
            
            e = sqrt(3)/6*( (1+sqrt(3))^(n+1)-(1-sqrt(3))^(n+1) );
            
            
        end
        
        
        
    case 'Sn' %OK
        
        if n==2
            
            e=6;
            
        else
            
            e = 2^(n-1)*(n+1);
            
        end
            
        
        
    case 'Kn'%OK
        
        e = 2^(n-1)*(n+1);
        
    case 'RGS_s' %OK -- is this global?
        
        if n>=3
            
            e=2^(n-2)*(3*n-1);
            
        end
        
    case 'RGS_d' %OK
        
        e = 2^((n-2)-1)*(9*(n-2)+3);
        
        
        
    case 'RGS_n_n_minus_1' %NOT OK
        
        
        e = 2^(n-(n+1)/2)*(26*(n-(n+1)/2)-22);
        
    case 'RGS_n_n' %NOT OK
        
        
        e = 2^(n-1)+6^(n-1)*(3+2*n);
        
        
        
    case 'Cn'
        
        if n>=5 %OK
            
            e = (1+sqrt(3))^n+(1-sqrt(3))^n-4/3*(2^(n-1)+(-1)^n) ;
            
        elseif n==4 %this is?
            
            e=44;
            
        elseif n==3 %%OK
            
            
            e = 2^(n-1)*(n+1);
            
            
            
        elseif n==2 %becomes path graph
            
            e=6;
           
            
        end
        
        
        
end


end