function [bool,identifier]=is_in_class_mu(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check if the graph belongs in class_mu.
%Input:  Adj: Adjacency matrix
%Output: bool: true or false
%        identifier: if the graph fails to be in class_mu, then we output
%        the reason this happens. if the graph is in class_mu, then we
%        output that it passed all the checks.


n    = length(Adj);
G    = graph(Adj);
degs = degree(G);


%========= Cond 1 ===========================================

if any((-1).^degs~=-1) %All nodes should have odd degrees.
    
    bool = false;
    identifier='failed in cond1';
    return
end

%========= Cond 2 ===========================================
%Bouchet says that we should have |nu(xy)|=|n(x) intersect n(y)| even for every xy of \bar{E}
%but Axel says that the symmetric difference should have even size.
%Not sure which one is correct. I will follow Bouchet's condition.
%I think that the 2 conditions are equivalent because if we passed the
%above then |n(x)| is 1 mod2 , |n(y)| is 1 mod2 and then
%|n(x)+n(y)| = |n(x)|+|n(y)|-2|n(x) \intersect n(y)|
%so it applying mod2 we have:
%|n(x)+n(y)| = 2 - 2|n(x) \intersect n(y)|
%and if |n(x) \intersect n(y)| is even
% then clearly 2-2*even is even-even = even.


Adj_bar = complement_graph(Adj);
   
bool_size = 'even_size'; %assume even size.

for v=1:n
    
   for w=v+1:n

       if Adj_bar(v,w)==1
       
           nu_xy = neighborhood_xy(Adj,v,w); %
           
           if (-1)^length(nu_xy) == -1 %odd
               
               bool_size = 'odd_size';
               
           end
               
           %[~,~,bool_size]=symmetric_difference_neighborhoods(Adj,v,w);

           if strcmpi(bool_size,'odd_size')

               bool=false;
           
               identifier='failed in cond2';
           
               return

           end

       end
   
       
   end

end

%========= Cond 3 ===========================================
%Check cycles of G. Check the property that |C|=|\nu(C)| (mod2)
%only for the basis of cycles. This means that if the cycle has even (odd) # of
%edges defining it, then the number of nnz elements in the binary rep of C
%should be even (odd).
%Suffices to check only basis of cycles based on the THM in Axel's paper.

[~,newcycles] = cycle_basis(Adj);
%nuC            = sparse(1,size(CB,2));

if isempty(newcycles)
    
    bool       = true;
    identifier = 'passed all';

    return
    
end


for jj=1:length(newcycles)
    
    this_cycle = newcycles{jj};
    this_edge  = this_cycle{1};
    nu_C       = neighborhood_xy(Adj,this_edge(1),this_edge(2));
    
    for ll=2:length(this_cycle)
        
        this_edge = this_cycle{ll};
        nu_C      = setxor(nu_C,neighborhood_xy(Adj,this_edge(1),this_edge(2))); %Addition is defined as setxor.
        
    end
    
    l_nuC = mod(length(nu_C),2);    
    lc    = mod(length(this_cycle),2);
    
    if l_nuC ~= lc
        
        bool=false;
        identifier='failed in cond3';
        return
        
    end
    
    
end
    
bool       = true;
identifier = 'passed all';


end