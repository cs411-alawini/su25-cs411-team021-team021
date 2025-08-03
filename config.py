from pathlib import Path
import os
from typing import Optional, Dict

_REQUIRED_DB_KEYS = {"MELODB_USER", "MELODB_PASS"}


def load_db_credentials(path: Optional[str] = None) -> Dict[str, str]:
    creds: Dict[str, str] = {}

    if path:
        p = Path(path)
        if not p.is_file():
            raise FileNotFoundError(f"Database-config file not found at {p}")
        for line in p.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            k, _, v = line.partition("=")
            creds[k.strip()] = v.strip()

    for key in _REQUIRED_DB_KEYS:
        if key not in creds and (val := os.getenv(key)):
            creds[key] = val

    missing = _REQUIRED_DB_KEYS - creds.keys()
    if missing:
        raise ValueError(
            f"Missing DB credential(s): {', '.join(sorted(missing))}. "
            "Provide them via a config file or environment variables."
        )

    return creds
