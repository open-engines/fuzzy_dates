from datetime import datetime
from fuzzy_parser.engine import Engine

start = datetime(2021, 4, 27).date()
(semantic, _) = Engine(start).when('11-09, št')
for single_date in semantic:
    print(single_date.strftime("%Y-%m-%d"))
