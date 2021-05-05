#!/usr/bin/env swipl
:- initialization(main, main).
:- [grammar].

main([Expression|_]) :-
  date_get(today, Context),
  parse(Context, Expression, Dates, Trace),
  write_ln(Dates), write_ln(Trace).
