# stack-overflow-data

1 - What tags on a Stack Overflow question lead to the most answers and the highest rate of approved answers for the current year? What tags lead to the least? How about combinations of tags?

2 - For posts which are tagged with only ‘python’ or ‘dbt’, what is the year over year change of question-to-answer ratio for the last 10 years? How about the rate of approved answers on questions for the same time period? How do posts tagged with only ‘python’ compare to posts only tagged with ‘dbt’?

3 - Other than tags, what qualities on a post correlate with the highest rate of answer and approved answer? Feel free to get creative

## Notes

The most recent date from posts_questions is from 2022, so we are not able to analyse the current year. I utilized 2022 as the year of the analysis, but the queries can be easily changed to a different year if necessary.

```sql
-- 2022-09-25 05:56:32.863000 UTC
SELECT MAX(creation_date) FROM bigquery-public-data.stackoverflow.posts_questions;
```

## 1.1 Single Tags

File `1_single_tags.sql` contains the query to find metrics about the number of answers and rate of approved answers.
It separates the tags from `tags` field and aggregate the values by each individual tag.

Here is the results for the single tags with `most answers`:

| Line  | tag        | question_count | total_answers | avg_answers_per_question | accepted_rate       |
|-------|------------|----------------|---------------|--------------------------|---------------------|
| 1     | python     | 202689         | 189565        | 1.4097196400684171       | 0.34979204594230628 |
| 2     | javascript | 139880         | 130590        | 1.4454430744028501       | 0.33235630540463251 |
| 3     | reactjs    | 75674          | 64493         | 1.3756452369779444       | 0.29282184105505177 |
| 4     | html       | 50524          | 51189         | 1.477998498585205        | 0.3399968331881878  |
| 5     | java       | 65190          | 50897         | 1.3348632274646597       | 0.26890627396839978 |
| 6     | c#         | 54166          | 45908         | 1.3233784952435861       | 0.32524092604216681 |
| 7     | pandas     | 35684          | 41921         | 1.4711703807685566       | 0.49770205133953588 |
| 8     | r          | 39675          | 40455         | 1.4421945741684783       | 0.44930056710775057 |
| 9     | css        | 35408          | 37915         | 1.4988535736875395       | 0.35429846362403961 |
| 10    | sql        | 30953          | 34074         | 1.4233082706766917       | 0.40267502342260836 |

As expected the most used programming languages and library/frameworks are in the top of the list.

For highest and lowest rate of approved answers, and lowest number of answers, the top of the list is filled with tags with 1 or 2 questions, so it was omitted here.
Because of that the analysis is not very useful. Here is a example of the `highest acceptance rate`:

| Line  | tag                     | question_count | total_answers | avg_answers_per_question | accepted_rate |
|-------|-------------------------|----------------|---------------|--------------------------|---------------|
| 1     | gdc                     | 2              | 2             | 1.0                      | 1.0           |
| 2     | mongojs                 | 2              | 2             | 1.0                      | 1.0           |
| 3     | sui                     | 1              | 1             | 1.0                      | 1.0           |
| 4     | zenhub                  | 1              | 1             | 1.0                      | 1.0           |
| 5     | difference-between-rows | 1              | 2             | 2.0                      | 1.0           |
| 6     | wren                    | 1              | 1             | 1.0                      | 1.0           |
| 7     | n3                      | 1              | 1             | 1.0                      | 1.0           |
| 8     | dynamicgridview         | 1              | 1             | 1.0                      | 1.0           |
| 9     | retrolambda             | 1              | 1             | 1.0                      | 1.0           |
| 10    | datashape               | 1              | 2             | 2.0                      | 1.0           |

Because of that I included an extra filter to only evaluate question with atleast 100 questions (arbitrary value; can be changed in the query).

Here is a example of `highest acceptant rate` with the filter applied :

| Line  | tag                   | question_count | total_answers | avg_answers_per_question | accepted_rate       |
|-------|-----------------------|----------------|---------------|--------------------------|---------------------|
| 1     | google-query-language | 277            | 339           | 1.2509225092250922       | 0.89891696750902517 |
| 2     | flatten               | 248            | 320           | 1.4414414414414412       | 0.76612903225806428 |
| 3     | kdb                   | 150            | 244           | 1.7553956834532376       | 0.71333333333333326 |
| 4     | raku                  | 155            | 230           | 1.6312056737588654       | 0.70322580645161292 |
| 5     | stringr               | 270            | 466           | 1.9176954732510285       | 0.69259259259259243 |
| 6     | purrr                 | 368            | 532           | 1.6319018404907975       | 0.68478260869565222 |
| 7     | jq                    | 824            | 1227          | 1.5299251870324191       | 0.67597087378640774 |
| 8     | jolt                  | 209            | 225           | 1.1538461538461537       | 0.66985645933014348 |
| 9     | python-polars         | 293            | 334           | 1.2651515151515151       | 0.66894197952218437 |
| 10    | data.table            | 696            | 1065          | 1.7487684729064039       | 0.66522988505747127 |

## 1.2 Multiple Tags

File `2_multiple_tags.sql` contains the code for analyse the data for multiple tags. Most of the query is the same as previous one.
The `tag_sets` CTE create all combinations possible for single and double tags (It's possible to create for 3 or more tags, but the combinations grows exponentially). In the end is possible to filter and order the table as needed.

Here is the result for questions with 2 tags for `most answers`:

| Line  | tag1       | tag2       | question_count | total_answers | avg_answers_per_question | accepted_rate       |
|-------|------------|------------|----------------|---------------|--------------------------|---------------------|
| 1     | pandas     | python     | 30987          | 37399         | 1.2069254848807562       | 0.5070190725142798  |
| 2     | javascript | reactjs    | 31341          | 30336         | 0.96793337800325441      | 0.33116365144698634 |
| 3     | css        | html       | 23125          | 27024         | 1.1686054054054047       | 0.37643243243243241 |
| 4     | html       | javascript | 23482          | 23701         | 1.0093262924793451       | 0.34315646026743896 |
| 5     | dataframe  | python     | 14562          | 18239         | 1.252506523829144        | 0.52808680126356256 |
| 6     | dataframe  | pandas     | 14241          | 18062         | 1.268309809704375        | 0.54090302647286026 |
| 7     | dart       | flutter    | 16144          | 16965         | 1.0508548067393462       | 0.3494796828543113  |
| 8     | python     | python-3.x | 15488          | 16526         | 1.0670196280991744       | 0.39282024793388431 |
| 9     | css        | javascript | 11686          | 12248         | 1.0480917336984426       | 0.3521307547492728  |
| 10    | javascript | node.js    | 14816          | 12126         | 0.81843952483801274      | 0.29663876889848823 |

## 2 dbt and Python tags

Similar with what I developed for single tags, but filtering ONLY the `dbt` and `python` tags. The query is available in `3_only_dbt_python.sql` file.
It also include the percentage change in relation of the last years for the metrics. I also included `3_1_dbt_python_tags` where we have the data from questions that `dbt` or `python` are not the ONLY tag.
Here is the result for the query:

| Line  | tag    | year | question_count | question_count_pct_change | avg_answers_per_question | question_to_answer_ratio_pct_change | accepted_answer_rate | accepted_answer_rate_pct_change |
|-------|--------|------|----------------|---------------------------|--------------------------|-------------------------------------|----------------------|---------------------------------|
| 1     | dbt    | 2020 | 31             | null                      | 1.3870967741935485       | null                                | 0.41935483870967738  | null                            |
| 2     | dbt    | 2021 | 58             | 0.87096774193548387       | 1.1379310344827585       | -0.17963111467522072                | 0.25862068965517243  | -0.3832891246684349             |
| 3     | dbt    | 2022 | 79             | 0.36206896551724138       | 1.0632911392405064       | -0.065592635212888134               | 0.27848101265822794  | 0.076793248945147982            |
| 4     | python | 2012 | 5749           | null                      | 2.6296747260393118       | null                                | 0.72082101234997353  | null                            |
| 5     | python | 2013 | 7819           | 0.36006261958601493       | 2.3107814298503642       | -0.12126720199697445                | 0.65174574753804815  | -0.095828594933339589           |
| 6     | python | 2014 | 8537           | 0.09182759943726819       | 1.9669673187302337       | -0.148786945696718                  | 0.61461871851938588  | -0.056965510183854082           |
| 7     | python | 2015 | 9781           | 0.14571863652336886       | 1.8998057458337594       | -0.03414473248077661                | 0.568960229015438    | -0.074287502362341051           |
| 8     | python | 2016 | 10344          | 0.057560576628156633      | 1.8339133797370459       | -0.034683738714452385               | 0.52523201856148494  | -0.076856356954198513           |
| 9     | python | 2017 | 11683          | 0.12944702242846096       | 1.6991354960198577       | -0.073491957257279653               | 0.49131216297183944  | -0.0645807079365531             |
| 10    | python | 2018 | 11614          | -0.0059060172900796031    | 1.6921818494919925       | -0.00409246145710793                | 0.49199242293783363  | 0.0013845779063954913           |
| 11    | python | 2019 | 14503          | 0.24875150680213534       | 1.7035096186995795       | 0.0066941795948158526               | 0.48810590912225055  | -0.0078995399814809075          |
| 12    | python | 2020 | 16256          | 0.12087154381852031       | 1.6496062992125984       | -0.03164250961384632                | 0.45497047244094468  | -0.067885751969060451           |
| 13    | python | 2021 | 15811          | -0.027374507874015748     | 1.5215356397444815       | -0.07763710621694915                | 0.43014357093162991  | -0.054568159942593439           |
| 14    | python | 2022 | 12809          | -0.18986781354753021      | 1.258177843703645        | -0.17308684013807479                | 0.35404793504567106  | -0.17690752815657923            |

## 3 Extras

I started using the [CORR](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/statistical_aggregate_functions#corr) function from BigQuery to find what are the correlations between the values in the columns listed below to the total answers and acceptance rate. This is a very naive approuch, but it can give a good starting point for the analysis. The query can be found in file `4.extras.sql`. The query is very inneficient, but as the dataset is small, it's not a problem. For better datasets, it's possible to use samples of the data to reduce the data scanned.

Columns:

- `length_of_question`: Total length of the body of the question
- `comment_count`: Total number of comments
- `favorite_count`: Total number of times the question was favorited
- `number_of_tags`: Total number of tags
- `view_count`: View count of the question

Here is the result of the query:

| Line  | corr_len_count      | corr_comments_count  | corr_favs_count   | corr_tagcount_count   | corr_views_count    | corr_len_accepted     | corr_comments_accepted | corr_favs_accepted   | corr_tagcount_accepted | corr_views_accepted  |
|-------|---------------------|----------------------|-------------------|-----------------------|---------------------|-----------------------|------------------------|----------------------|------------------------|----------------------|
| 1     | -0.0271274846108237 | 0.021335309256145026 | 0.190003902122527 | -0.032001195109331339 | 0.16178983048195933 | 0.0090526590710129032 | -0.0027039508189792409 | 0.029690791128870728 | -0.013709249853263066  | 0.044372179172857865 |

The only columns that have modest correlation with the total number of answers are the number of views and number of favorites. None have a good correlation with the accepted rate of answers. This is kind of expected as questions with more views will probably have more answers.

Diving into the relation between the number of views and number of answers, the last query divide the data in question with more than 100 views or less.
It shows that we have more answers per question in average and also a higher accepted rate for the questions.

| Line  | has_more_than_100_views | question_count | total_answers | avg_answers_per_question | accepted_rate       |
|-------|-------------------------|----------------|---------------|--------------------------|---------------------|
| 1     | true                    | 359507         | 371192        | 1.0325028441727144       | 0.37323890772641416 |
| 2     | false                   | 909280         | 666327        | 0.732807276086574        | 0.27769333978532484 |

The results are exploratory and naive, but they show that other columns could affect the number of answers and the acceptance rate of them. With more time it would be possible to evaluate better the data.
