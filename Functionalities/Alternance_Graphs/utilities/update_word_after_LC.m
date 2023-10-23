function new_word = update_word_after_LC(init_word,LCnodes)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to apply local complementation on the word level.
%
%Input:  init_word: the input word
%         LC_nodes: an array of nodes corresponding to the LC sequence
%Output:  new_word: The updated word

for jj=1:length(LCnodes)
    
    new_word = init_word;
    
    pos                     = find(new_word == LCnodes(jj));
    new_word(pos(1):pos(2)) = flip(new_word(pos(1):pos(2)));
    init_word               = new_word;
    
end

end