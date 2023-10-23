%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

close all;
clc;
clear;

n=3;

Adj=create_RGS(n,1:2*n,n,'Adjacency');



figure(1)
plot(graph(Adj))

[bool,m]=is_circleG(Adj);
% layout='force';
% formatOption='EdgeList';
% 
% [out,G] = four_regular_multigraph(m,formatOption,layout);


%The general script for constructing the word based on circle graphs
%gives a different m word

m=double_occurrence_RGS(n); %This is another way to construct the word for RGS only


EdgeList_F4=double_occur_words_to_multigraph(m,'EdgeList');


G = graph(EdgeList_F4{1}(:,1),EdgeList_F4{1}(:,2));

figure(2)
plot(G,'layout','circle')

