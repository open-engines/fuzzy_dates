:- use_module(library(date_time)).
:- multifile adverb/4.
:- multifile dayName/3.
:- multifile month/3.

adverb(french, 'aujourd\'hui', Date, Date).
adverb(french, 'demain', Date, Tomorrow) :- date_add(Date, days(1), Tomorrow).

dayName(french, 1, lundi).
dayName(french, 2, mardi).
dayName(french, 3, mercredi).
dayName(french, 4, jeudi).
dayName(french, 5, vendredi).
dayName(french, 6, samedi).
dayName(french, 7, dimanche).

month(french, 1, janv).
month(french, 2, févr).
month(french, 3, mars).
month(french, 4, avril).
month(french, 5, mai).
month(french, 6, juin).
month(french, 7, juil).
month(french, 8, août).
month(french, 9, sept).
month(french, 10, oct).
month(french, 11, nov).
month(french, 12, déc).
