function nu_xy = neighborhood_xy(Adj,x,y)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%This function can be define for every non-ordered pair of distinct
%vertices x and y. It outputs the intersection of the neighborhood of two
%vertices x and y.
%Input: Adj: Adjacency matrix
%         x: first node
%         y: second node
%Output: The nodes which are adjacent to both x and y.

Nx    = Get_Neighborhood(Adj,x);
Ny    = Get_Neighborhood(Adj,y);
nu_xy = intersect(Nx,Ny);



end