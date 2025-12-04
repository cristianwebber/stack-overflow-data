-- The most recent date from posts_questions is from 2022, so we are not able to analyse the current year
-- 2022-09-25 05:56:32.863000 UTC
SELECT MAX(creation_date) FROM bigquery-public-data.stackoverflow.posts_questions;

-- Correlation analysis between different question features and answer count/accepted answer
WITH questions AS (
    SELECT
        id AS question_id
        , SPLIT(TRIM(tags), '|') AS tags_array
        , LENGTH(body) as length_of_question
        , comment_count
        , favorite_count
        , ARRAY_LENGTH(SPLIT(TRIM(tags), '|')) number_of_tags
        , view_count
        , CASE WHEN accepted_answer_id IS NULL THEN 0 ELSE 1 END AS has_accepted_answer
    FROM bigquery-public-data.stackoverflow.posts_questions
    WHERE EXTRACT(YEAR FROM creation_date) >= 2022
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
        , q.tags_array
        , q.length_of_question
        , q.comment_count
        , q.favorite_count
        , q.number_of_tags
        , q.has_accepted_answer
        , q.view_count
        , IFNULL(a.answer_count,0) AS answer_count
    FROM questions q
    LEFT JOIN answers a
        ON q.question_id = a.question_id
)

SELECT
    CORR(length_of_question, answer_count) AS corr_len_count,
    CORR(comment_count, answer_count) AS corr_comments_count,
    CORR(favorite_count, answer_count) AS corr_favs_count,
    CORR(number_of_tags, answer_count) AS corr_tagcount_count,
    CORR(view_count, answer_count) AS corr_views_count,
    CORR(length_of_question, has_accepted_answer) AS corr_len_accepted,
    CORR(comment_count, has_accepted_answer) AS corr_comments_accepted,
    CORR(favorite_count, has_accepted_answer) AS corr_favs_accepted,
    CORR(number_of_tags, has_accepted_answer) AS corr_tagcount_accepted,
    CORR(view_count, has_accepted_answer) AS corr_views_accepted
FROM fact;

-- Diving into the relation between the number of views and number of answers
WITH questions AS (
    SELECT
        id AS question_id
        , view_count
        , CASE WHEN accepted_answer_id IS NULL THEN 0 ELSE 1 END AS has_accepted_answer
    FROM bigquery-public-data.stackoverflow.posts_questions
    WHERE EXTRACT(YEAR FROM creation_date) >= 2022
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
        , q.view_count
        , q.view_count > 100 as has_more_than_100_views
        , q.has_accepted_answer
        , IFNULL(a.answer_count,0) AS answer_count
    FROM questions q
    LEFT JOIN answers a
        ON q.question_id = a.question_id
)

SELECT
    has_more_than_100_views
    , COUNT(question_id) AS question_count
    , IFNULL(SUM(answer_count), 0) AS total_answers
    , IFNULL(AVG(answer_count), 0) AS avg_answers_per_question
    , AVG(has_accepted_answer) AS accepted_rate
FROM fact
GROUP BY all
LIMIT 10;
