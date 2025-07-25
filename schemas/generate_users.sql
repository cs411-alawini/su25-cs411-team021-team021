-- GCP MySQL maximum lines for information_schema is 4284 lines
INSERT INTO User (username)
SELECT CONCAT('user', LPAD(n, 6, '0'))
FROM (
  SELECT @rownum := @rownum + 1 AS n
  FROM information_schema.columns, (SELECT @rownum := 0) r
  LIMIT 1000
) x
ORDER BY RAND();