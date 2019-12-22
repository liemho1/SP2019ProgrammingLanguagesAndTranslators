% Assume each undirected graph is specified as a list of edgesg0([[1,2], [2,3], [3,4], [1,5]]).
% Assume each edge is specified asa list of 2 vertices: [vertex, vertex]

% This graph is completely connected. Your relation should return true(or something
% other than false).
g1([[1,2], [2,4], [4,3], [3,1], [1,4], [3,2]]).

% This graph is NOTcompletely connected. Your relation should return false
% g2([[1,2], [3,4], [4,1], [2,3]]).

:- dynamic(edge/2).

isConnected(Vert,Edge) :-
    Edge is Vert*(Vert-1) // 2.

completelyConnectedGraph([],Vert).
completelyConnectedGraph([H|T], Vert) :-
    [First,Second] = H,
    assert(edge(First,Second)),
    completelyConnectedGraph(T, Vert),
    aggregate_all(count, edge(X,Y), Count),
    isConnected(Vert,Edge),
    Edge=:=Count.

clear() :-
    retractall(edge(_,_)).














