:- use_module(library(date_time)).
:- multifile adverb/4.
:- multifile dayName/3.
:- multifile month/3.

adverb(german, 'Heute', Date, Date).
adverb(german, 'Morgen', Date, Tomorrow) :- date_add(Date, days(1), Tomorrow).

dayName(german, 1, 'Montag').
dayName(german, 2, 'Dienstag').
dayName(german, 3, 'Mittwoch').
dayName(german, 4, 'Donnerstag').
dayName(german, 5, 'Freitag').
dayName(german, 6, 'Samstag').
dayName(german, 7, 'Sonntag').

month(german, 1, 'Januar').
month(german, 2, 'Februar').
month(german, 3, 'März').
month(german, 4, 'April').
month(german, 5, 'Mai').
month(german, 6, 'Juni').
month(german, 7, 'Juli').
month(german, 8, 'August').
month(german, 9, 'September').
month(german, 10, 'Oktober').
month(german, 11, 'November').
month(german, 12, 'Dezember').

