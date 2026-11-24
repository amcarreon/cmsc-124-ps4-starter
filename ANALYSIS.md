# The Search and the Stack

Replace this paragraph after your checks pass. Paste the output of `./trace`
for one case. Then answer three questions about it.

## Trace: P08 — `ancestor(tom, X)`

P08 asks Prolog to find every ancestor-related answer for `tom`. In the starter knowledge base, `ancestor/2` has its direct-parent clause first and its recursive clause second. The trace below follows the facts and the four-port tracer in `scripts/trace_case.pl`.

```text
== trace P08 ==
Call: ancestor(tom,X)
  Call: parent(tom,X)
  Exit: parent(tom,liz)
Exit: ancestor(tom,liz)
answer 1: X=liz
Redo: ancestor(tom,liz)
  Redo: parent(tom,liz)
  Exit: parent(tom,bob)
Exit: ancestor(tom,bob)
answer 2: X=bob
Redo: ancestor(tom,bob)
  Redo: parent(tom,bob)
  Fail: parent(tom,X)
  Call: parent(tom,_)
  Exit: parent(tom,liz)
  Call: ancestor(liz,X)
    Call: parent(liz,X)
    Fail: parent(liz,X)
    Call: parent(liz,_)
    Fail: parent(liz,_)
  Fail: ancestor(liz,X)
  Redo: parent(tom,liz)
  Exit: parent(tom,bob)
  Call: ancestor(bob,X)
    Call: parent(bob,X)
    Exit: parent(bob,ann)
  Exit: ancestor(bob,ann)
Exit: ancestor(tom,ann)
answer 3: X=ann
Redo: ancestor(tom,ann)
  Redo: ancestor(bob,ann)
    Redo: parent(bob,ann)
    Exit: parent(bob,pat)
  Exit: ancestor(bob,pat)
Exit: ancestor(tom,pat)
answer 4: X=pat
Redo: ancestor(tom,pat)
  Redo: ancestor(bob,pat)
    Redo: parent(bob,pat)
    Fail: parent(bob,X)
    Call: parent(bob,_)
    Exit: parent(bob,ann)
    Call: ancestor(ann,X)
      Call: parent(ann,X)
      Exit: parent(ann,sue)
    Exit: ancestor(ann,sue)
  Exit: ancestor(bob,sue)
Exit: ancestor(tom,sue)
answer 5: X=sue
Redo: ancestor(tom,sue)
  Redo: ancestor(bob,sue)
    Redo: ancestor(ann,sue)
      Redo: parent(ann,sue)
      Fail: parent(ann,X)
      Call: parent(ann,_)
      Exit: parent(ann,sue)
      Call: ancestor(sue,X)
        Call: parent(sue,X)
        Fail: parent(sue,X)
        Call: parent(sue,_)
        Fail: parent(sue,_)
      Fail: ancestor(sue,X)
      Redo: parent(ann,sue)
      Fail: parent(ann,_)
    Fail: ancestor(ann,X)
    Redo: parent(bob,ann)
    Exit: parent(bob,pat)
    Call: ancestor(pat,X)
      Call: parent(pat,X)
      Exit: parent(pat,jim)
    Exit: ancestor(pat,jim)
  Exit: ancestor(bob,jim)
Exit: ancestor(tom,jim)
answer 6: X=jim
Redo: ancestor(tom,jim)
  Redo: ancestor(bob,jim)
    Redo: ancestor(pat,jim)
      Redo: parent(pat,jim)
      Fail: parent(pat,X)
      Call: parent(pat,_)
      Exit: parent(pat,jim)
      Call: ancestor(jim,X)
        Call: parent(jim,X)
        Fail: parent(jim,X)
        Call: parent(jim,_)
        Fail: parent(jim,_)
      Fail: ancestor(jim,X)
      Redo: parent(pat,jim)
      Fail: parent(pat,_)
    Fail: ancestor(pat,X)
    Redo: parent(bob,pat)
    Fail: parent(bob,_)
  Fail: ancestor(bob,X)
  Redo: parent(tom,bob)
  Fail: parent(tom,_)
Fail: ancestor(tom,X)
== 6 answers ==
```

- Which of its lines push a frame onto Activity 15's runtime stack? Which
  lines pop one?

Each `Call` line marks a goal being entered for the first time. It corresponds to pushing a fresh activation frame for that goal, with its arguments and the information needed to continue after the goal finishes. For example, `Call: ancestor(tom,X)` enters the main query, and the indented `Call` lines enter the `parent/2` and recursive `ancestor/2` goals used to solve it. The indentation shows how deeply a goal is nested under the query.

An `Exit` line marks a successful return from that goal, so it corresponds conceptually to popping its active frame after producing a solution. A `Fail` line marks that the goal has no remaining clause that can succeed; that unsuccessful attempt also finishes and its active frame is removed. The trace contains multiple `Exit` and `Redo` events for the same goal because Prolog searches for more than one answer. These ports describe the logical search; they do not show every physical stack operation of a particular Prolog implementation.

- What does a `Redo` line resume that a returned frame cannot?

A `Redo` line resumes a goal's unfinished search for additional solutions. Prolog returns to the choice point for that goal, restores the variable bindings needed for that point, and tries another available clause or fact. For example, after `parent(tom,X)` first succeeds with `X=liz`, `Redo: parent(tom,liz)` indicates that Prolog is looking for another matching parent fact. It then finds `X=bob`. The recursive `ancestor/2` calls also redo when Prolog needs to explore another parent branch.

This is different from an ordinary return in Activity 15. A normally returned frame has finished and been popped; its local activation record cannot simply be resumed to try another alternative. Prolog's choice point preserves the remaining alternatives and the state needed to backtrack to them. Therefore, `Redo` represents resuming a saved search, not starting a completely new call.

- Why does swapping the two clauses of `reach/2` change whether the search
  ever answers, while swapping the two clauses of `ancestor/2` only changes
  the order of the answers?

The difference is the position and structure of the recursive call.

In the starter knowledge base, `reach/2` is defined with its recursive clause first:

```prolog
reach(X, Y) :-
    reach(X, Z),
    edge(Z, Y).
reach(X, Y) :-
    edge(X, Y).
```

For `reach(a,d)`, Prolog enters the first clause and immediately calls `reach(a,Z)` again. That recursive call happens before the rule checks an `edge/2` fact that could bind `Z` and move the search forward. Because Prolog uses depth-first, left-to-right search, it keeps following the same left-recursive pattern and does not reach the second, direct-edge clause. It can therefore loop without producing an answer. If the direct-edge clause is placed first, Prolog can test an edge before recursing and can follow the path `a -> b -> c -> d` to produce an answer. The graph contains a cycle, so further backtracking can still continue searching around that cycle.

The `ancestor/2` clauses have a different structure:

```prolog
ancestor(A, D) :-
    parent(A, D).
ancestor(A, D) :-
    parent(A, P),
    ancestor(P, D).
```

The recursive clause first calls `parent(A,P)`. This checks the finite family facts and binds `P` before the recursive `ancestor(P,D)` call is made. Each recursive step therefore moves to a parent in the family hierarchy rather than immediately calling the same unbound goal again. Since the family relationships are finite and contain no cycle, both clause orders can finish and find the same six answers for `ancestor(tom,X)`. Putting the recursive clause first changes which branch is explored first, so it changes the answer order, but it does not create the non-terminating left recursion seen in `reach/2`.

For P08, the base-clause-first order returns `liz`, `bob`, `ann`, `pat`, `sue`, and `jim`. With the recursive clause first, the same set is reached in a different order: `sue`, `jim`, `ann`, `pat`, `liz`, and `bob`.

The connection to Activity 15 is that each `Call` represents an active goal with its own execution state, while `Redo` shows Prolog returning to saved alternatives. Clause order determines which branch is entered first. If the first branch recurses without making progress, as in `reach/2`, depth-first search may never reach a later clause that could answer. If recursion is preceded by a goal that makes progress, as in `ancestor/2`, changing clause order can change the order of answers without changing whether the search terminates.
