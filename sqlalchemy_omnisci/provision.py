"""Override some methods for the provision module."""
from sqlalchemy.testing.provision import temp_table_keyword_args


@temp_table_keyword_args.for_db("omnisci")
def _omnisci_temp_table_keyword_args(cfg, eng):
    return {}
