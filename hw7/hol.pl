% You should find 0 triangles in this graph
%g0 is [[1,2], [2,3], [3,4], [1,5]].
% You should find 2 triangles in this graph
%g2([[1,2], [2,3], [3,1], [3,4], [4,2], [4,5]]).
% You should find 3 triangles in this graph
%g3([[2,1], [2,4], [1,3], [1,4], [3,2], [3,5], [5,6], [6,3], [4,2]]).

:- dynamic(edge/2).

triangle(X,Y,Z) :-
    edge(X,Y),
    edge(Y,Z),
    edge(Z,X).
        
countTriangles([],0).
countTriangles([H|T],Counter) :-
    [First,Second] = H,
    assert(edge(First,Second)),
    countTriangles(T,C),
    aggregate_all(count, triangle(X,Y,Z), Count),
    Counter is Count // 3.

