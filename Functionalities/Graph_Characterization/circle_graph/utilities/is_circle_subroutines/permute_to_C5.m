function m = permute_to_C5(AdjCn,Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%

P0    = eye(5); 
perm5 = perms(1:5);

for jj=1:size(perm5,1)

  this_perm = perm5(jj,:);
  P         = P0;
  P(:,1:5)  = P(:,this_perm);

  if all(all(P*Adj*P'==AdjCn))

      m    = double_occurrence_Cn(5,this_perm,false);
      test = double_occur_words_to_graphs(m,'Adjacency');
      test = test{1};
      
      if ~all(all(test==Adj))
          
          close all
          figure(1)
          plot(graph(test))
          figure(2)
          plot(graph(Adj))
         
          error('Error in permutation of Adj to C5.')
          
      end
      
      return

  end

end


end
