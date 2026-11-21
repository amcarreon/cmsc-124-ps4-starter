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

## P01

The `parent/2` facts are tried in source order, so `parent(tom,liz)` binds `X` to `liz` first and `parent(tom,bob)` is the next answer. There are exactly two matching facts, so the search then fails and the count is 2.

## P02

The query unifies with the fact `parent(tom,bob)`, so the ground goal succeeds once. No other clause can produce another proof for this fact, so there is no second answer and the count is 1.

## P03

No `parent/2` fact has `tom` as its second argument, so unification with every parent fact fails. The query has no solutions, giving `false`, `none`, and a count of 0.

## P04

The first unification makes `X` identical to `f(Y,a)`; the following goal `Y=b` then binds the variable inside that term. The resulting single answer is `X=f(b,a),Y=b`, and there is no alternative unification.

## P05

Unifying the two compound terms matches their `f/2` functors and then unifies corresponding arguments, binding `X=a` and `Y=b`. This is one successful unification with no alternative, so the count is 1.

## P06

The distinct atoms `a` and `b` cannot be made identical by unification, so the goal fails immediately. There are no bindings or alternative clauses, hence no second answer and a count of 0.

## P07

The `grandparent/2` body first tries `parent(tom,P)` and then `parent(P,X)`: `P=liz` has no children, while `P=bob` produces `X=ann` followed by `X=pat`. Fact order therefore gives two answers and then exhaustion.

## P08

The base `ancestor/2` clause first returns Tom’s direct children, `liz` and `bob`. The recursive clause then follows Tom’s children in fact order: Liz has no descendants, while Bob’s descendants are `ann`, `pat`, `sue`, and `jim`, giving six answers total in the order `liz`, `bob`, `ann`, `pat`, `sue`, `jim`.

## P09

Write one to three sentences here. Name the rule that fixes each field.

## P10

Write one to three sentences here. Name the rule that fixes each field.

## P11

Write one to three sentences here. Name the rule that fixes each field.

## P12

Write one to three sentences here. Name the rule that fixes each field.

## P13

Write one to three sentences here. Name the rule that fixes each field.

## P14

Write one to three sentences here. Name the rule that fixes each field.

## P15

Write one to three sentences here. Name the rule that fixes each field.

## P16

Write one to three sentences here. Name the rule that fixes each field.

