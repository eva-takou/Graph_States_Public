%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%%
clear;
clc;

n=5;

Adj0=create_random_graph(n);

[bool,~]=is_circleG(Adj0);

%%

if bool

    l=count_l_Bouchet(Adj0);

    disp(['The size of the orbit is:',num2str(l)])

    Adj_LC_Method1 = Map_Out_Orbit(Adj0,'bruteforce');

    if l~=length(Adj_LC_Method1)
        
        error('Did not map out entire orbit.')
        
    end
    
    iters=10*l;
    
    
    [store_word,Adj_LC_Method2]=Generate_LC_words(Adj0,iters);
    
    if length(Adj_LC_Method2)~=length(Adj_LC_Method1)
       
        error('Found different # of adjacency matrices for LC graphs.')
        
    end
    
    cnt=0;
    
    for k1=1:l
        
        for k2=1:l
           
            if all(all(Adj_LC_Method1{k1}==Adj_LC_Method2{k2}))
            
                cnt=cnt+1;
            
                break
                
            end
                
        end
        
        
    end
    
    if cnt~=l
        
        error('Did not find the same graphs.')
        
    end
    
    
end