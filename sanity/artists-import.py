#!/usr/bin/env python

import ndjson
import os
from pyairtable import Table

api_key = os.environ["AIRTABLE_API_KEY"]
base_id = os.environ["AIRTABLE_BASE_ID"]
home_dir = os.environ["HOME"]

table = Table(api_key, base_id, 'artists')

with open(f"{home_dir}/Downloads/artists.ndjson", "w", encoding="utf-8") as f:
    for row in table.iterate():
        ndjson.dump(row, f)
