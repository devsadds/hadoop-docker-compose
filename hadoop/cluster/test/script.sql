DROP TABLE IF EXISTS my_test_table_4;

CREATE TABLE IF NOT EXISTS my_test_table_4 (
  id INT,
  name STRING,
  description STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  status BOOLEAN
);

SHOW TABLES;

-- Вставляем 1000 случайных записей
FROM (
  SELECT stack(
    1000,
    -- Пример генерации случайных значений для каждого поля
    -- Здесь используется функция rand() для генерации случайных чисел
    -- и функции from_unixtime() и unix_timestamp() для случайных дат
    -- Функции concat() и cast() используются для создания строк и приведения типов
    -- true/false выбираются случайно с помощью rand() > 0.5
    CAST(rand()*1000 AS INT), CONCAT('Name_', CAST(rand()*1000 AS INT)), CONCAT('Description_', CAST(rand()*1000 AS INT)),
    from_unixtime(unix_timestamp() - CAST(rand()*10000000 AS INT)),
    from_unixtime(unix_timestamp() - CAST(rand()*10000000 AS INT)),
    CASE WHEN rand() > 0.5 THEN true ELSE false END
  ) AS (id, name, description, created_at, updated_at, status)
) AS subquery
INSERT INTO my_test_table_4 (id, name, description, created_at, updated_at, status);

SELECT * FROM my_test_table_4;
DESCRIBE my_test_table_4; -- Исправил на my_test_table_4