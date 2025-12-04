WITH questions AS (
    SELECT
        id AS question_id
        , SPLIT(TRIM(tags), '|') AS tags_array
        , answer_count
        , CASE WHEN accepted_answer_id IS NULL THEN 0 ELSE 1 END AS has_accepted_answer
    FROM bigquery-public-data.stackoverflow.posts_questions
    WHERE EXTRACT(YEAR FROM creation_date) = 2022
)
, answers AS (
    SELECT
        parent_id AS question_id
        , COUNT(*) AS answer_count
    FROM bigquery-public-data.stackoverflow.posts_answers
    WHERE EXTRACT(YEAR FROM creation_date) >= 2022
    GROUP BY parent_id
)
, fact_questions AS (
    SELECT
        questions.question_id
        , questions.tags_array
        , questions.has_accepted_answer
        , IFNULL(answers.answer_count, 0) AS answer_count
    FROM questions
    LEFT JOIN answers
        ON questions.question_id = answers.question_id
)
, tag_sets AS (
    SELECT
        question_id
        , has_accepted_answer
        , answer_count
        -- create combinations of single tags and tag pairs.
        -- We can extend this to 3 or more, but the number of combinations grow quickly
        , ARRAY(
            SELECT AS STRUCT
                tag AS tag1
            , CAST(NULL AS STRING) AS tag2
            FROM UNNEST(tags_array) AS tag
        ) AS singles
        , ARRAY(
            SELECT AS STRUCT
                LEAST(a,b) AS tag1
            , GREATEST(a,b) AS tag2
            FROM UNNEST(tags_array) a
            JOIN UNNEST(tags_array) b
            ON a < b
        ) AS pairs
    FROM fact_questions
)
, unnested_sets AS (
    SELECT
        question_id
        , has_accepted_answer
        , answer_count
        , combo.tag1
        , combo.tag2
    FROM tag_sets
        , UNNEST(ARRAY_CONCAT(singles, pairs)) AS combo
)

SELECT
    tag1
    , tag2
    , COUNT(*) AS question_count
    , SUM(answer_count) AS total_answers
    , AVG(answer_count) AS avg_answers_per_question
    , AVG(has_accepted_answer) AS accepted_rate
FROM unnested_sets
GROUP BY tag1, tag2
-- comment/uncomment to change the ordering
-- Most answers:
HAVING tag2 IS NOT NULL
ORDER BY total_answers DESC

-- Least answers:
-- HAVING tag2 IS NOT NULL
-- ORDER BY total_answers ASC

-- Highest rate of approved answers:
-- HAVING tag2 IS NOT NULL
-- ORDER BY accepted_rate DESC

-- Lowers rate of approved answers:
-- HAVING tag2 IS NOT NULL
-- ORDER BY accepted_rate ASC
LIMIT 10;
