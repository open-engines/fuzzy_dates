:- use_module(library(date_time)).
:- multifile adverb/4.
:- multifile dayName/3.
:- multifile month/3.

adverb(swedish, 'Idag', Date, Date).
adverb(swedish, 'Imorgon', Date, Tomorrow) :- date_add(Date, days(1), Tomorrow).

dayName(swedish, 1, måndag).
dayName(swedish, 2, tisdag).
dayName(swedish, 3, onsdag).
dayName(swedish, 4, torsdag).
dayName(swedish, 5, fredag).
dayName(swedish, 6, lördag).
dayName(swedish, 7, söndag).

month(swedish, 1, januari).
month(swedish, 2, februari).
month(swedish, 3, mars).
month(swedish, 4, april).
month(swedish, 5, maj).
month(swedish, 6, juni).
month(swedish, 7, juli).
month(swedish, 8, augusti).
month(swedish, 9, september).
month(swedish, 10, oktober).
month(swedish, 11, november).
month(swedish, 12, december).
