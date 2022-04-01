from unittest import TestCase
from datetime import datetime, date

from fuzzy_parser.engine import Engine


class TestEngine(TestCase):

    def test_present_adverb(self):
        """
        An adverb
        """
        (semantic, syntax) = Engine(datetime(2021, 1, 1).date()).when("Aujourd'hui")
        self._validate([date(2021, 1, 1)], semantic)
        self._validate(['adverb(French)'], syntax)

    def test_single_abbreviated_week_day_and_month_utf_8(self):
        """
        Single explicit week day and month using UTF-8
        """
        semantic, syntax = Engine(datetime(2021, 4, 27).date()).when('7 PAŹ')
        self._validate([date(2021, 10, 7)], semantic)
        self._validate(['dm(abbreviated(Polish))'], syntax)

    def test_single_explicit_week_day_and_month(self):
        """
        Single explicit week day and month
        """
        semantic, syntax = Engine(datetime(2021, 4, 27).date()).when('Tisdag, 18 Maj')
        self._validate([date(2021, 5, 18)], semantic)
        self._validate(['sd(wd(Swedish), dm(explicit(Danish)))'], syntax)

    def test_single_explicit_week_day_and_day_dot(self):
        """
        Single explicit week day and day dot
        """
        semantic, syntax = Engine(datetime(2021, 4, 27).date()).when('Freitag, 7. Mai')
        self._validate([date(2021, 5, 7)], semantic)
        self._validate(['sd(wd(German), dm(explicit(French)))'], syntax)

    def test_explicit_post_fixed_months_and_abbreviations(self):
        """
        Explicit post-fixed months and abbreviations
        """
        (semantic, syntax) = Engine(datetime(2021, 4, 27).date()).when('28. Aug. - 1. Sept.')
        self._validate([date(2021, 8, 28), date(2021, 9, 1)], semantic)
        self._validate(['dm(abbreviated(Danish))', 'dm(abbreviated(Danish))'], syntax)

    def test_explicit_post_fixed_months_without_abbreviations(self):
        """
        Explicit post-fixed months without abbreviations
        """
        (semantic, syntax) = Engine(datetime(2021, 4, 27).date()).when('21 Juin - 9 Juil.')
        self._validate([date(2021, 6, 21), date(2021, 7, 9)], semantic)
        self._validate(['dm(explicit(French))', 'dm(abbreviated(French))'], syntax)

    def test_implicit_start_month_and_abbreviated_end(self):
        """
        Implicit start month and abbreviated end
        """
        semantic, syntax = Engine(datetime(2021, 4, 27).date()).when('12. - 14. Aug.')
        self._validate([date(2021, 5, 12), date(2021, 8, 14)], semantic)
        self._validate(['d(unknown)', 'dm(abbreviated(Danish))'], syntax)

    def test_implicit_start_month_and_post_fixed_explicit_end(self):
        """
        Implicit start month and post-fixed explicit end
        """
        semantic, syntax = Engine(datetime(2021, 4, 27).date()).when('12 - 14 Mai')
        self._validate([date(2021, 5, 12), date(2021, 5, 14)], semantic)
        self._validate(['d(unknown)', 'dm(explicit(French))'], syntax)

    def test_post_fixed_start_month_and_implicit_end(self):
        """
        Post-fixed start month and implicit end
        """
        semantic, syntax = Engine(datetime(2021, 4, 27).date()).when('21 Juin - 9')
        self._validate([date(2021, 6, 21), date(2021, 7, 9)], semantic)
        self._validate(['dm(explicit(French))', 'd(unknown)'], syntax)

    # Time Machine Tests
    def test_present_prefixed_start_month_and_implicit_end(self):
        """
        Prefixed start month and implicit end
        """
        (semantic, syntax) = Engine(datetime(2021, 5, 6).date()).when('Maj 6 - 14')
        self._validate([date(2021, 5, 6), date(2021, 5, 14)], semantic)
        self._validate(['md(explicit(Danish))', 'd(unknown)'], syntax)

    def test_future_prefixed_start_month_and_implicit_end(self):
        """
        Prefixed start month and implicit end
        """
        (semantic, syntax) = Engine(datetime(2021, 5, 5).date()).when('Maj 6 - 14')
        self._validate([date(2021, 5, 6), date(2021, 5, 14)], semantic)
        self._validate(['md(explicit(Danish))', 'd(unknown)'], syntax)

    def test_past_prefixed_start_month_and_implicit_end(self):
        """
        Past prefixed start month and implicit end
        """
        (semantic, syntax) = Engine(datetime(2021, 4, 27).date()).when('Januari 1 - 14')
        self._validate([date(2022, 1, 1), date(2022, 1, 14)], semantic)
        self._validate(['md(explicit(Dutch))', 'd(unknown)'], syntax)

    def _validate(self, expected, actual):
        self.assertEqual(expected, actual, 'expected value {0} actual value {1}'.format(expected, actual))
