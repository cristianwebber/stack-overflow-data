WITH questions AS (
    SELECT
        id AS question_id
        , tags as tag
        , EXTRACT(YEAR FROM creation_date) AS year
        , CASE WHEN accepted_answer_id IS NULL THEN 0 ELSE 1 END AS has_accepted_answer
    FROM bigquery-public-data.stackoverflow.posts_questions
    WHERE
        EXTRACT(YEAR FROM creation_date) >= 2012
        -- filter only relevant tags
        AND tags IN ('python', 'dbt')
)

, answers AS (
    SELECT
        parent_id AS question_id
        , COUNT(*) AS answer_count
    FROM bigquery-public-data.stackoverflow.posts_answers
    GROUP BY parent_id
)

, fact AS (
    SELECT
        q.question_id
        , q.year
        , q.tag
        , q.has_accepted_answer
        , IFNULL(a.answer_count,0) AS answer_count
    FROM questions q
    LEFT JOIN answers a
        ON q.question_id = a.question_id
)

, yearly AS (
    SELECT
        tag
        , year
        , COUNT(*) AS question_count
        , SUM(answer_count) AS total_answers
        , AVG(answer_count) AS avg_answers_per_question
        , AVG(has_accepted_answer) AS accepted_answer_rate
    FROM fact
    GROUP BY tag, year
)

SELECT
    tag
    , year
    , question_count
    , SAFE_DIVIDE(
        question_count - LAG(question_count) OVER(PARTITION BY tag ORDER BY year),
        LAG(question_count) OVER(PARTITION BY tag ORDER BY year)
    ) AS question_count_pct_change
    , avg_answers_per_question
    , SAFE_DIVIDE(
        avg_answers_per_question - LAG(avg_answers_per_question) OVER(PARTITION BY tag ORDER BY year),
        LAG(avg_answers_per_question) OVER(PARTITION BY tag ORDER BY year)
    ) AS question_to_answer_ratio_pct_change
    , accepted_answer_rate
    , SAFE_DIVIDE(
        accepted_answer_rate - LAG(accepted_answer_rate) OVER(PARTITION BY tag ORDER BY year),
        LAG(accepted_answer_rate) OVER(PARTITION BY tag ORDER BY year)
    ) AS accepted_answer_rate_pct_change
FROM yearly
ORDER BY tag, year
