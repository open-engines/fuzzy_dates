import os

from pyswip import Prolog, Query, Functor, Variable
from datetime import date


class Engine:
    """

    """

    def __init__(self, context=date.today()):
        self.context = Functor("date", 3)(context.year, context.month, context.day)
        Prolog().consult(os.path.join(os.path.dirname(__file__), 'grammar.pl'))

    def when(self, time_expression: str):
        """
        Explore all possible solutions to exhaust the generator bellow and close the query
        :param time_expression:
        :return:
        """
        return next(iter([solution for solution in (self._parse_fuzzy_dates(self, time_expression))]), ([], []))

    @staticmethod
    def _parse_fuzzy_dates(self, time_expression):
        dates, trace = Variable(), Variable()
        query = Query(Functor("parse", 4)(self.context, time_expression,  dates, trace))
        while query.nextSolution():
            semantic = [eval(period.value, {'date': date}) for period in dates.value]
            syntax = [trace.value for trace in trace.value]
            yield semantic, syntax
        query.closeQuery()

