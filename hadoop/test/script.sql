USE test_db_1;
DROP TABLE IF EXISTS my_test_table_1;
drop database test_db_1;
create database test_db_1;
USE test_db_1;
CREATE TABLE IF  not EXISTS  my_test_table_1 (
  id INT,
  name STRING,
  created_at TIMESTAMP
);
SHOW TABLES;
INSERT INTO my_test_table_1 (id, name, created_at) VALUES (1, 'Alice', CURRENT_TIMESTAMP),(2, 'Bob', CURRENT_TIMESTAMP);
SELECT * FROM my_test_table_1;
DESCRIBE my_test_table_1;