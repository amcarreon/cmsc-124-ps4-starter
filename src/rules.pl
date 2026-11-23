%%%% rules.pl -- Part 2. Write the seven predicates below.
%%%%
%%%% The grader loads the facts and given rules in cases/kb.pl before this
%%%% file, so parent/2, edge/2, elem/2, join/3, and len/2 are yours to call.
%%%% The grader scores R1, R2, and R3 separately. Finish them in order. You
%%%% keep every group you get right.
%%%%
%%%% Each stub below throws, so a check you did not reach fails with a
%%%% message that identifies the predicate. Replace the whole stub, head and
%%%% body, with your own clauses. A stub left above your clauses runs first
%%%% and throws before Prolog tries yours.

%%% R1 -- the family.

% sibling(X, Y): X and Y share a parent and are not the same person.
%
% Order matters. X \= Y succeeds only when X and Y are already bound to
% different things, so put it after the goal that binds them.
sibling(_, _) :-
    throw(not_implemented(sibling/2)).

% cousin(X, Y): a parent of X and a parent of Y are siblings.
cousin(_, _) :-
    throw(not_implemented(cousin/2)).

% descendant(D, A): A is an ancestor of D.
%
% Two clauses, the mirror image of ancestor/2 in cases/kb.pl. The base
% clause reads one parent fact. The recursive clause reads one parent fact
% and then asks a smaller question.
descendant(_, _) :-
    throw(not_implemented(descendant/2)).

%%% R2 -- lists.

% count_of(X, List, N): X occurs N times in List. N is 0 for the empty
% list, which is your base case.
count_of(_, _, _) :-
    throw(not_implemented(count_of/3)).

% rev(List, Reversed): Reversed holds the elements of List in the other
% order. Reverse the tail. Then use join/3 to put the head at the end.
rev([], []).                % empty list reversed is just empty list
rev([X], [X]).              % base case: reversed of 1-element list is itself
rev([H|T], R):-             % recursive clause: gets the head and tail,
    rev(T, RT),             % reverses the tail
    join(RT, [H], R).       % joins head at the end of reversed tail

% last_of(List, X): X is the last element of List. The empty list has no
% last element, so last_of([], X) must fail.
last_of([X], X).            % base case: last element of 1-element list is itself
last_of([_, H|T], X):-      % recursive clause: drops the first element,
    last_of([H|T], X).      % and recurses list of the remaining elements
                            % until the last element remains at base case


%%% R3 -- the graph.

% route(From, To, Path): Path is the list of nodes from From to To, in
% order, following edge/2 and never visiting a node twice. A route from a
% node to itself is [From].
%
% reach_r/2 in cases/kb.pl walks the same graph and never ends, because
% the cycle a -> b -> c -> a always offers one more edge. Carry the nodes
% you visited. Refuse to step onto one again. \+ Goal is true when Goal
% cannot be proved. That is how you say "not yet visited."
route(X, Y, P) :-
    travel(X, Y, [X], P).   % Visited is the current node
    
% travel(From, To, Visited, Path): Visited holds every node visited so far,
% there we check if we already went on the node
% Base case is when From and To are the same, so the path is itself
travel(X, X, _, [X]).

% Recursive clause: takes one edge(From, Next) and refuses to continue if 
% the Next is already in Visited using \+ elem(Next, Visited). Recurses
% from the Next which is Z to the new Next node Y, adds the node Z to Visited, then 
% travels to the following nodes on route of From to To repeats until base case
travel(X, Y, V, [X|NV]):-   % [X|NV] is the path from X to the path of next
    edge(X, Z),
    \+ elem(Z, V),
    travel(Z, Y, [Z|V], NV).
