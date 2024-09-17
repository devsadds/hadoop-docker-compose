DROP TABLE IF EXISTS my_test_table_3;
CREATE TABLE IF  not EXISTS  my_test_table_3 (
  id INT,
  name STRING,
  desc STRING
);
SHOW TABLES;
INSERT INTO my_test_table_3 (id, name, desc) VALUES (5, 'Alice', 'disc1'),(6, 'Bob', 'disc2');
SELECT * FROM my_test_table_3;
DESCRIBE my_test_table_3;