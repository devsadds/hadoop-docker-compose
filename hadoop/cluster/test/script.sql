DROP TABLE IF EXISTS my_test_table_3;
CREATE TABLE IF  not EXISTS  my_test_table_3 (
  id INT,
  name STRING,
  created_at TIMESTAMP
);
SHOW TABLES;
INSERT INTO my_test_table_3 (id, name, created_at) VALUES (3, 'Alice', CURRENT_TIMESTAMP),(4, 'Bob', CURRENT_TIMESTAMP);
SELECT * FROM my_test_table_3;
DESCRIBE my_test_table_3;