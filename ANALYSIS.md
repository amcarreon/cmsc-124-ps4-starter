# The Search and the Stack

Replace this paragraph after your checks pass. Paste the output of `./trace`
for one case. Then answer three questions about it.

## Trace: P01 — `parent(tom, X)`

The following is the trace for P01. It shows the two `parent/2` facts for `tom` being tried in the order in which they appear in `cases/kb.pl`.

```text
== trace P01 ==
Call: parent(tom, X)
Exit: parent(tom, liz)
answer 1: X=liz
Redo: parent(tom, liz)
Exit: parent(tom, bob)
answer 2: X=bob
Redo: parent(tom, bob)
Fail: parent(tom, X)
== 2 answers ==
```

- Which of its lines push a frame onto Activity 15's runtime stack? Which
  lines pop one?

`Call: parent(tom, X)` is the point where the `parent/2` goal is entered, so it corresponds to pushing an activation frame for that goal. The `Exit` line marks successful completion of that attempt, while the final `Fail` line marks that the goal has no more clauses to try; these are the completion points corresponding to the goal's frame being returned from or removed. In this trace, the two `Exit` lines show two successful solutions of the same query goal, not two different source-level calls written by the user.

`Redo` is different: it shows Prolog going back into a goal that previously succeeded because the surrounding search needs another solution. It is not a fresh source-level call like a new `Call`; it resumes the existing goal's remaining alternatives. The trace is a logical view of Prolog's search, so it does not display every physical stack operation of a particular Prolog implementation. The push/return comparison to Activity 15 is a conceptual one.

- What does a `Redo` line resume that a returned frame cannot?

A `Redo` resumes the unfinished search state for a goal: in particular, its remaining clause alternatives and the bindings/choice point needed to try them. In P01, after `parent(tom, liz)` succeeds, Prolog can redo `parent/2` and try the next matching fact, `parent(tom, bob)`. After the second solution, it redoes the goal once more and discovers that no further fact matches, producing `Fail`.

A normally returned frame in Activity 15 has finished its call and is popped. Its local activation record is no longer available to continue execution. Prolog's backtracking mechanism must therefore preserve a choice point and the state needed to revisit alternatives; `Redo` represents that return to an earlier point in the search rather than an ordinary forward return to the caller.

- Why does swapping the two clauses of `reach/2` change whether the search
  ever answers, while swapping the two clauses of `ancestor/2` only changes
  the order of the answers?

The original `reach/2` in `cases/kb.pl` is left-recursive:

```prolog
reach(X, Y) :-
    reach(X, Z),
    edge(Z, Y).
reach(X, Y) :-
    edge(X, Y).
```

For the query `reach(a, d)`, Prolog tries the first clause before the edge/base clause. That clause immediately calls `reach(a, Z)` again, before reading any `edge/2` fact that could constrain `Z` or move the search forward. With Prolog's depth-first, left-to-right search, it keeps entering the same recursive goal and does not reach the second clause. Consequently, this clause order can loop before producing an answer. If the edge clause is placed first, Prolog can make progress by following an edge before making a recursive call; it can then find the path from `a` to `d` (although the cycle can still cause further search after an answer).

`ancestor/2` has a different structure:

```prolog
ancestor(A, D) :-
    parent(A, D).
ancestor(A, D) :-
    parent(A, P),
    ancestor(P, D).
```

Its base clause checks a parent fact, and its recursive clause first checks a `parent/2` fact before asking the smaller recursive question. The family facts form a finite, acyclic parent hierarchy, so the recursive search makes progress toward a base case. Reversing the clauses to make the recursive clause first therefore changes which valid descendants are found first, but it does not create the immediate left-recursive loop found in `reach/2`. The set of answers remains the same; only their order changes.

This is the key connection to Activity 15: an ordinary call frame explains the active calls and their local state, but Prolog also needs choice points to remember alternatives. Clause order determines which call is explored first, and depth-first search may become trapped in a recursive branch before it reaches another available clause.
