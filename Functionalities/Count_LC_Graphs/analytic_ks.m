function k=analytic_ks(n,graphtype)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%


switch graphtype
    
    
    case 'Pn' %OK
        
        if n==2
            
            k = 6;
            
        elseif n>2
            
            k = 4;
            
            
        end
        
        
        
    case 'Sn' %OK
        
        if n==2
            
            k=6;
            
        else
            
            k = 2^(n-1);
            
        end
            
        
        
    case 'Kn' %OK
        
        k = 2^(n-1);
        
    case 'RGS_s'  %OK
        
        k = 2^(n-2);
        
        
    case 'RGS_d' %OK
        
        k = 2^(n-3);

    case 'RGS_t' %OK
        
        k = 2^(n-4);
        
        

    case 'RGS_n_n_minus_1'  %OK
        
        k = 2^(n-(n+1)/2);
            
        
    case 'RGS_n_n'  
        
        k = 2^(n/2);
        
    case 'Cn' %OK
        
        if n>=5
            
            k = 1 ;
            
        elseif n==4 
            
            k=4;
            
        elseif n==3 %becomes the Kn
            
            
            k = 2^(n-1);
            
            
            
        elseif n==2 %becomes path graph
            
            k=4;
           
            
        end
        
        
        
end




end