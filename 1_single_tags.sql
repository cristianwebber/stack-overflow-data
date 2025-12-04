WITH questions AS (
  SELECT
    id AS question_id
    -- question can have multiple tags divide by pipe
    , SPLIT(TRIM(tags), '|') AS tags_array
    , answer_count -- data match with posts_answers SUM result, with exception of question 70945864.
    , CASE WHEN accepted_answer_id IS NULL THEN 0 ELSE 1 END AS has_accepted_answer
  FROM bigquery-public-data.stackoverflow.posts_questions
  -- Working with data from 2022 because it is the most recent data we have
  WHERE EXTRACT(YEAR FROM creation_date) = 2022
)

, answers AS (
  SELECT
    parent_id AS question_id
    , COUNT(*) AS answer_count
  FROM bigquery-public-data.stackoverflow.posts_answers
  -- Limit the data as we can not have answers before the question date
  WHERE EXTRACT(YEAR FROM creation_date) >= 2022
  GROUP BY question_id
)

, fact_questions AS (
  SELECT
    questions.question_id
    , questions.tags_array
    , questions.has_accepted_answer
    -- I will use only answer_count from now on. It's almost the same as question_total_answers
    , SUM(questions.answer_count) AS question_total_answers
    , SUM(answers.answer_count) as answer_count
  FROM questions
  LEFT JOIN answers
    ON questions.question_id = answers.question_id
  GROUP BY question_id, tags_array, has_accepted_answer
)

-- Single tag
SELECT
    tag
    , COUNT(questions.question_id) AS question_count
    , IFNULL(SUM(questions.answer_count), 0) AS total_answers
    , IFNULL(AVG(questions.answer_count), 0) AS avg_answers_per_question
    , AVG(questions.has_accepted_answer) AS accepted_rate
FROM fact_questions AS questions
-- one question can have multiple tags, need to unnest to get counts by individual tag
, UNNEST(tags_array) AS tag
GROUP BY tag

-- comment/uncomment to change the ordering
-- Most answers:
ORDER BY total_answers DESC

-- Least answers:
-- HAVING question_count >= 100
-- ORDER BY total_answers ASC

-- Highest rate of approved answers:
-- HAVING question_count >= 100
-- ORDER BY accepted_rate DESC

-- Lowers rate of approved answers:
-- HAVING question_count >= 100
-- ORDER BY accepted_rate ASC
LIMIT 10;
