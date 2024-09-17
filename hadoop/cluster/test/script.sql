DROP TABLE IF EXISTS my_test_table_4;

CREATE TABLE IF NOT EXISTS my_test_table_4 (
  id INT,
  name STRING,
  description STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  status BOOLEAN
);

-- Вставляем 100 случайных записей в my_test_table_4
-- Используем цикл от 0 до 99 для генерации строк
INSERT INTO my_test_table_4
SELECT 
  -- Для id используем номер итерации цикла + 1
  s.rn + 1 AS id,
  -- Для name создаем случайное имя, используя номер итерации
  CONCAT('Name_', CAST(s.rn AS STRING)) AS name,
  -- Для description создаем случайное описание
  CONCAT('Description_', CAST(s.rn AS STRING)) AS description,
  -- Генерируем случайную дату для created_at
  from_unixtime(unix_timestamp('2020-01-01', 'yyyy-MM-dd') + s.rn * 60 * 60 * 24) AS created_at,
  -- Генерируем случайную дату для updated_at, отличную от created_at
  from_unixtime(unix_timestamp('2020-01-01', 'yyyy-MM-dd') + (s.rn + 50) * 60 * 60 * 24) AS updated_at,
  -- Случайным образом присваиваем статус true или false
  CASE WHEN rand() > 0.5 THEN true ELSE false END AS status
FROM (
  SELECT posexplode(split(space(99),' ')) AS (rn, val)
) s;

-- Проверяем содержимое таблицы
SELECT * FROM my_test_table_4;

-- Описание структуры таблицы
DESCRIBE my_test_table_4;