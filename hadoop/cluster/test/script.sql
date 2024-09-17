DROP TABLE IF EXISTS my_test_table_4;
CREATE TABLE IF  not EXISTS  my_test_table_4 (
  id INT,
  name STRING,
  desc STRING
);
SHOW TABLES;
INSERT INTO my_test_table_4 (id, name, desc) VALUES (5, 'Alice', 'disc1'),(6, 'Bob', 'disc2');
SELECT * FROM my_test_table_4;
DESCRIBE my_test_table_3;