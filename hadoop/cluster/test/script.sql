DROP TABLE IF EXISTS my_test_table_4;

CREATE TABLE IF NOT EXISTS my_test_table_4 (
  id INT,
  name STRING,
  description STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  status BOOLEAN
);

-- Вставляем 5000 случайных записей в my_test_table_4
-- Используем генератор строк, чтобы создать множество строк
INSERT INTO my_test_table_4
SELECT 
  row_number() OVER () AS id, -- Генерируем уникальный ID для каждой строки
  CONCAT('Name_', CAST(FLOOR(RAND() * 5000) AS STRING)) AS name,
  CONCAT('Description_', CAST(FLOOR(RAND() * 5000) AS STRING)) AS description,
  CURRENT_TIMESTAMP AS created_at, -- Используем текущий таймстемп для демонстрации
  CURRENT_TIMESTAMP AS updated_at, -- Используем текущий таймстемп для демонстрации
  IF(RAND() > 0.5, TRUE, FALSE) AS status -- Случайно выбираем статус
FROM
  (SELECT EXPLODE(ARRAY(SEQUENCE(1, 5000))) AS id) t;

-- Проверяем содержимое таблицы
SELECT * FROM my_test_table_4;

-- Описание структуры таблицы
DESCRIBE my_test_table_4;