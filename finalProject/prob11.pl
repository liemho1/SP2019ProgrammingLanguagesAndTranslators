% Dave has 5200 frequent flier miles, etc.
frequentFlierMiles(dave,5200).
frequentFlierMiles(susan,2500).

% Susan works for the airline, etc.
worksForAirline(susan).
worksForAirline(bob).

% There is a 260 mile flight from St. Louis to Chicago, etc.
flight(stLouis,chicago,260).
flight(chicago,losAngeles,1750).
flight(stLouis,denver,786).
flight(denver,losAngeles,843).
flight(losAngeles,honolulu,2553).

% Chicago is an airport hub, etc.
isHub(chicago).
isHub(losAngeles).

% You can fly from X to Y and it will take Miles miles if…
canFly(X,Y,Miles) :- flight(X,Y,Miles).
canFly(X,Y,Miles) :- flight(X,Z,Miles1), canFly(Z,Y,Miles2), Miles is Miles1 + Miles2.

% Who can fly for free from From to To if…
canFlyForFree(From,To,Who) :-
canFly(From,To,Miles),
isHub(From),
frequentFlierMiles(Who,Credits),
Credits >= Miles.