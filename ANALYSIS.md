# The Search and the Stack

`./trace` of `ancestor/2`
```
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

`Call` line indicates a goal or a fresh frame being pushed onto the runtime stack. For instance, `Call: ancestor(tom,X)` is the main query, the inner `Call` for `parent/2` and recursive `ancestor/2` are the nested goals to solve the main. `Exit` line means a successful return from that call; hence, popping frames after return. `Fail` line is an attempted goal without an answer due to lack of information in knowledge base, still popping the frame. `Redo` line searches for other possible answers in that particular query after backtracking and finds another available clause or fact to explore. For example, after `parent(tom,X)` first succeeds with `X=liz`, `Redo: parent(tom,liz)` indicates that Prolog is looking for another match. It then finds `X=bob`. The recursive `ancestor/2` calls also redo when Prolog needs to explore another parent branch.

In contrast with Act15, A returned frame has finished and been popped; its locally saved state cannot run an alternative. In here, it preserves the remaining alternatives and the state needed to backtrack. Therefore, `Redo` represents resuming a saved search, not starting a completely new call.

The difference is the position and structure of the recursive call. For `reach(a,d)`, it immediately goes through the recursive call of `reach(a,Z)`. Without the checking of the base case clause to find an edge first, it will repeatedly call the recursion due to the same pattern it reaches without any binding of `Z`. This results in an unbounded outcome. With base clause first, Prolog can check the edge first, and recurse from there to produce an answer. The graph contains a cycle, so further backtracking can still continue searching around that cycle.

The recursion checks for the binding of `P` first before proceeding with the recursive call of `ancestor(P,D)`. Hence, it moves from one parent to another based on the hierarchy. Since it is finite and the clause order checks for the base clause first, it will not result in an unbounded solution, and gives 6 answers for `ancestor(tom,X)`.

The base case first of P08 is `liz`, `bob`, `ann`, `pat`, `sue`, and `jim`. While recursive clause first is the same but different order: `sue`, `jim`, `ann`, `pat`, `liz`, and `bob`.

In comparison with Act15, `Call` represents an active frame with execution state, while `Redo` is the saved alternatives. Clause order determines which branch is entered first. If the first branch recurses without making progress, as in `reach/2`, depth-first search may never a solution. If recursion checks a goal with progress first, as in `ancestor/2`, changing clause order can change the order of answers without changing whether the search terminates.
