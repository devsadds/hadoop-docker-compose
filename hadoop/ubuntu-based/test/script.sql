DROP TABLE IF EXISTS my_test_table_1;
CREATE TABLE IF  not EXISTS  my_test_table_1 (
  id INT,
  name STRING,
  created_at TIMESTAMP
);
SHOW TABLES;
INSERT INTO my_test_table_1 (id, name, created_at) VALUES (3, 'Alice', CURRENT_TIMESTAMP),(4, 'Bob', CURRENT_TIMESTAMP);
SELECT * FROM my_test_table_1;
DESCRIBE my_test_table_1;