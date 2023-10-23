function [bool,m]=is_circleG(Adj,verbose)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Non-recursive implementation of circle graph recognition based on
%Bouchet's algorithm.
%
%Ref: Reducing prime graphs and recognizing circle graphs, Bouchet,
%Combinatorica 7, 243-254 (1987)
%     

Adj0=Adj;
[bool_split_free,~,~]=is_split_free_brute(Adj0,false);

if bool_split_free %if no splits were detected then we can go ahead and construct the word.
        
    [bool,m]=is_circleG_subroutine(Adj);
    
    return
        
end

%If splits were detected, we need to construct the word for each split-free
%part of the initial splits. we then glue together the subgraphs to
%construct the word.

level            = 1;
fixed_nodes      = 1:length(Adj);
indx_choice      = 1;
flag_enter_loop  = true;
dummy_node       = -1;
cnt              = 0;

while true
    
    if flag_enter_loop 
        
        [~,split,bipartite_nodes] = is_split_free_brute(Adj,false);
        
        for k=1:2 

            Vk   = split{k}{1};
            a_k  = bipartite_nodes{k}{1};
            Adjk = Adj(:,Vk);
            Adjk = Adjk(Vk,:);

            Adjk = [Adjk,sparse(length(Adjk),1)];   %extra column
            Adjk = [Adjk;sparse(1,length(Adjk))];   %put extra row
            LAk  = length(Adjk);

            for ll=1:length(a_k) %Put connections between "v" and bipartite nodes. "v" is considered to be the last column.

                indx = find(Vk==a_k(ll));
                Adjk = Adjk+sparse([indx,LAk],[LAk,indx],1,LAk,LAk);

            end 

            %disp(['For (level,k)=[',num2str([level,k]),'] nodes in adjacency before relabeling: ',num2str(Vk)])
            
            for jj=1:length(Vk)

                Vk(jj)=fixed_nodes(Vk(jj));

            end

            %disp(['For (level,k)=[',num2str([level,k]),'] nodes in adjacency after relabeling: ',num2str(Vk)])
            
            for jj=1:length(a_k)

                a_k(jj)=fixed_nodes(a_k(jj));

            end        

            stack_Adj{level}{k}        = Adjk;
            stack_node_names{level}{k} = Vk;
            stack_processed{level}{k}  = false;
           
        end  
        
    end
    
    this_Adj            = stack_Adj{level}{indx_choice};
    Vk                  = stack_node_names{level}{indx_choice};
    [bool_split_free_k] = is_split_free_brute(this_Adj,false);
    
    if bool_split_free_k
        
        [bool_circle_k,mk] = is_circleG_subroutine(this_Adj);
        
        if ~bool_circle_k %everything failed, return
            
            bool = false;
            m    = [];
            return
        
        else
                    
            %disp(['For level=',num2str(level),' word before relabeling: ',num2str(mk)])
            
            temp = mk;
            
            for p=1:length(Vk)
            
                temp(mk==p) = Vk(p);
                
            end
            
            temp(mk==max(mk)) = dummy_node;
            mk                = temp;

            %disp(['For level=',num2str(level),' word after relabeling: ',num2str(mk)])
            
            store_mk{level}{indx_choice}=mk;
            stack_processed{level}{indx_choice} = true;
            cnt=cnt+1;
        end
        
        indx_choice     = 2;
        flag_enter_loop = false;
        
    else
        
        level           = level+1;
        Adj             = this_Adj;
        fixed_nodes     = [Vk,dummy_node]; %Plus the additional dummy node in the end?
        dummy_node      = dummy_node-1;
        indx_choice     = 1;
        flag_enter_loop = true;
        %disp(['Fixed nodes for next level: ',num2str(fixed_nodes)])
        
        continue
        
    end
    
    
    
    if indx_choice==2 && stack_processed{level}{2} %I think exit cond is now ok.
        
        for k=1:2
        
            [break_cond(k)] = is_split_free_brute( stack_Adj{level}{indx_choice},false);
        
        end
        
        if all(break_cond)
           
            break 
            
        end
        
    end
    
    
    
end

%Now reconstruct the words starting from the bottom:

for jj=length(store_mk):-1:2

    
    last_words = store_mk{jj};
    m1         = last_words{1};
    m2         = last_words{2};
    
    %do circshift till we have the dummy node in first position -- this is
    %just for convenience--we preserve the same alternances
    indx1 = find(m1==dummy_node,1);
    indx2 = find(m2==dummy_node,1);
    
    if indx1~=1
       
        for kk=1:indx1-1
           
            m1=circshift(m1,-1);
            
        end
        
    end
    
    if indx2~=1
       
        for kk=1:indx2-1
           
            m2=circshift(m2,-1);
            
        end
        
    end
    
    %Connect the words through the dummy node.
    
    locs1 = find(m1==dummy_node);
    locs2 = find(m2==dummy_node);
    
    %word is of the form m1=vA1vB1
    A1 = m1(2:locs1(2)-1);
    B1 = m1(locs1(2)+1:end);    
    A2 = m2(2:locs2(2)-1);
    B2 = m2(locs2(2)+1:end);    
    
    word = [A1,A2,B1,B2];
    
    %Fill in the previous level:
    store_mk{jj-1}{2} = word;
    
    %Increase value of dummy node by +1.
    dummy_node = dummy_node+1;
    
end

m1    = store_mk{1}{1};
m2    = store_mk{1}{2};

indx1 = find(m1==dummy_node,1);
indx2 = find(m2==dummy_node,1);

if indx1~=1

    for kk=1:indx1-1

        m1=circshift(m1,-1);

    end

end

if indx2~=1

    for kk=1:indx2-1

        m2=circshift(m2,-1);

    end

end

locs1 = find(m1==dummy_node);
locs2 = find(m2==dummy_node);

A1 = m1(2:locs1(2)-1);
B1 = m1(locs1(2)+1:end);
A2 = m2(2:locs2(2)-1);
B2 = m2(locs2(2)+1:end);

m = [A1,A2,B1,B2];

%Finally test if the word is correct:
if ~is_correct_word(Adj0,m)
    error('Did not produce correct word.')
end

bool=true;

end