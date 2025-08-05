UPDATE User
SET password_hash = SHA2('password', 256);