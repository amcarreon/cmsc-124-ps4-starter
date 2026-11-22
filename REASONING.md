<!--no-pdf-->
# Why Each Prediction Reads the Way It Does

Write one entry per case, before you run anything. Name the rule behind each
predicted field. One to three sentences is enough. The grader checks the
structure of this file only. It does not judge how good the reasoning is, and
it sets no word minimum.

For every case you predicted wrongly, add a short correction after you run
it: what you predicted, what the language printed, and which rule you
misread. Corrections belong in the correction commits, not the prediction
commit.

Commit this file together with `predictions.tsv`, before any case runs:

```bash
git add predictions.tsv REASONING.md
```

The example below uses a query that is not one of the 16 cases, so it gives
no answer away. `parent(pat, X)` reads `parent(pat, jim)` because the `parent`
facts are tried top to bottom and only that one has `pat` as its first
argument:

```text
## parent(pat, X)

The goal scans the parent facts in source order. Only parent(pat, jim) has
pat first, so X binds to jim. No second fact matches, so the first ; finds
nothing and the search ends after one answer.
```

## parent(tom, X)

The `parent/2` facts are tried in source order, so `parent(tom,liz)` binds `X` to `liz` first and `parent(tom,bob)` is the next answer. There are exactly two matching facts, so the search then fails and the count is 2.

## parent(tom, bob)

The query unifies with the fact `parent(tom,bob)`, so the ground goal succeeds once. No other clause can produce another proof for this fact, so there is no second answer and the count is 1.

## parent(X, tom)

No `parent/2` fact has `tom` as its second argument, so unification with every parent fact fails. The query has no solutions, giving `false`, `none`, and a count of 0.

## X = f(Y, a), Y = b

The first unification makes `X` identical to `f(Y,a)`; the following goal `Y=b` then binds the variable inside that term. The resulting single answer is `X=f(b,a),Y=b`, and there is no alternative unification.

## f(X, b) = f(a, Y)

Unifying the two compound terms matches their `f/2` functors and then unifies corresponding arguments, binding `X=a` and `Y=b`. This is one successful unification with no alternative, so the count is 1.

## a = b

The distinct atoms `a` and `b` cannot be made identical by unification, so the goal fails immediately. There are no bindings or alternative clauses, hence no second answer and a count of 0.

## grandparent(tom, X)

The `grandparent/2` body first tries `parent(tom,P)` and then `parent(P,X)`: `P=liz` has no children, while `P=bob` produces `X=ann` followed by `X=pat`. Fact order therefore gives two answers and then exhaustion.

## ancestor(tom, X)

The base `ancestor/2` clause first returns Tom’s direct children, `liz` and `bob`. The recursive clause then follows Tom’s children in fact order: Liz has no descendants, while Bob’s descendants are `ann`, `pat`, `sue`, and `jim`, giving six answers total in the order `liz`, `bob`, `ann`, `pat`, `sue`, `jim`.

## ancestor_r(tom, X)

The recursive clause comes first, so it looks for `parent(tom,P), ancestor_r(P,X)`, based on the given facts, in order, it tries at `parent(tom,liz)` first but fails at `ancestor_r(liz,X)` since `liz` has no children, so it tries the next fact `parent(tom,bob)`, and the trace is `tom -> bob -> ann -> sue`, so the first answer is `X=sue`. On backtracking, Prolog finds the given facts: `tom -> bob -> pat -> jim`, so `X=jim` is the second answer. As it backtracks, the parents of `jim` and `sue` also works because their parent is `bob`, so  `X=ann` and `X=pat`, and Prolog proceeds to the base clause `parent(tom,X)` which is `X=liz` and `X=bob`, giving a total of 6 answers.

## ancestor(X, jim)

In the rule, the base clause comes first, and based on the given facts, `parent(pat,jim)`, the first answer is `X=pat`. On backtrack, the recursive clause `parent(X, P), ancestor(P, jim).`, the trace of the fact order is `tom -> bob -> pat -> jim`, `parent(tom,bob)` since `bob` is an ancestor of `jim`, `X=tom` for the second. `parent(bob,pat)` works too since `pat` is a parent of `jim`, so `bob` is an ancestor, hence `X=bob` for the third, giving 3 answers.

## reach(a, d)

The recursive call comes first so `reach(a,d)` calls `reach(a,Z)`, then calls `reach(a,Z)`, again with no end, and no edge fact was read, the Prolog just calls continuously because of the clause order. Making all the three fields `unbounded`.

## reach_r(a, d)

Here, the base clause comes first, `edge(a,d)` fails, and recurses `edge(a,Z), reach_r(Z,d)`, so we find `Z=b`, calls again `reach_r(b,d)`, so we find `Z=c`, and with `c` it hits the base case at first fact `edge(c, d)` which makes the answers true. When it backtracks, `reach_r(c,d)` recurses `edge(c,a)` gives `Z=a`, calling the starting argument and repeats the cycle for another true answer. Hence, the count is unbounded.

## len([a, b, c], N)

This case exhausts the list, it calls `len([b,c],M)`, then `len([c],M)`, then `len([],M)` hitting the base case. When backtracking, the last call is `M=0` based on fact `len([],0)`, at second call `len([c],M)` M increments, so `M=1`, and at the `len([b,c],M)`, `M=2`, so that gives `N=2+1`, `N=3`. There are no other possible answers since all facts and rules were already exhausted.

## join(X, Y, [1, 2])

The base clause runs first `join([], L, L)`, unifying with `X=[]` and `Y=L=[1,2]`, so that’s the first answer. When it backtracks, the recursive clause runs `join([H|T], L, [H|R])` where `[H|R]` matches with `[1,2]`, so `H=1`, and `R=[2]`, and `X=[1|T]`, so the body is now `join(T,Y,[2])`. At base case, we now have the second answer `X = [1]` and  `Y = [2]`. On backtracking again, it takes `H=2` and `R=[]`, and the body becomes `join(T,Y,[])`, giving the values of `X=[1,2]` and `Y=[]`, which makes it 3 answers.

## X > 2, elem(X, [1, 2, 3])

X is not bounded when X > 2, so the query throws instantiation error, which is `error` in the grader's notation for all the three fields, aborting the query. The `elem(X, [1, 2, 3])` is not reached.

## elem(X, [1, 2, 3]), X > 2

`elem` binds `X` to `1`, then exits with `X=1`, so `X > 2` is `1 > 2`, which is a fail. Prolog backtracks `elem` for 2 and binds it with `X`, also a fail at `2 > 2`. Then backtracks again at `X=3`, it succeeds for `3 > 2`, and backtracks to exhaust other possible answers, ends up with none so the answer is just `X=3`.
