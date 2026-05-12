-- Cấu hình MySQL Server
SET GLOBAL sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY';
SET PERSIST sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,ONLY_FULL_GROUP_BY';

SET GLOBAL time_zone = '+07:00';
SET PERSIST time_zone = '+07:00';

SET GLOBAL character_set_server = 'utf8mb4';
SET PERSIST character_set_server = 'utf8mb4';

SET GLOBAL collation_server = 'utf8mb4_unicode_ci';
SET PERSIST collation_server = 'utf8mb4_unicode_ci';

SET GLOBAL max_connections = 1000;
SET PERSIST max_connections = 1000;

-- Kiểm tra: SELECT @@global.sql_mode, @@global.time_zone, @@global.character_set_server, @@global.collation_server, @@global.max_connections;
