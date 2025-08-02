from pathlib import Path


def load_db_credentials(path: str | None = None) -> dict:
    path = Path(path)

    if not path.is_file():
        raise FileNotFoundError(
            f"Database-config file not found at {path}. "
        )

    creds = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        k, _, v = line.partition("=")
        creds[k.strip()] = v.strip()

    missing = {"DB_HOST", "DB_USER", "DB_PASS", "DB_NAME"} - creds.keys()
    if missing:
        raise ValueError(f"Missing keys in db_config.txt: {', '.join(sorted(missing))}")
    return creds
