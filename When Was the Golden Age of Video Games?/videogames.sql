/* The ten best-selling video games */
-- Select all information for the top ten best-selling games
-- Order the results from best-selling game down to tenth best-selling

SELECT *
FROM game_sales
ORDER BY games_sold;

/* Missing review scores */
/* There are somes game data without reviews */

-- Join games_sales and reviews
-- Select a count of the number of games where both critic_score and user_score are null

SELECT COUNT(*)
FROM game_sales
LEFT JOIN reviews ON game_sales.game = reviews.game
WHERE (reviews.critic_score IS NULL) AND (reviews.user_score IS NULL);

/* Years that video game critics loved */
-- Select release year and average critic score for each year, rounded and aliased
-- Join the game_sales and reviews tables
-- Group by release year
-- Order the data from highest to lowest avg_critic_score and limit to 10 results

SELECT year, ROUND(AVG(critic_score), 2) AS avg_critic_score
FROM game_sales
INNER JOIN reviews
ON game_sales.game = reviews.game
GROUP BY year
ORDER BY avg_critic_score DESC
LIMIT 10;

/* Was 1982 really that great? */
-- Paste your query from the previous task; 
-- Update it to add a count of games released in each year called num_games
-- Update the query so that it only returns years that have more than four reviewed games

SELECT year, ROUND(AVG(critic_score), 2) AS avg_critic_score, COUNT(game_sales.game) AS num_games
FROM game_sales
INNER JOIN reviews
ON game_sales.game = reviews.game
GROUP BY year
HAVING COUNT(game_sales.game) > 4
ORDER BY avg_critic_score DESC
LIMIT 10;

/* Years that dropped off the critics' favorites list */
-- Select the year and avg_critic_score for those years that dropped off the list of critic favorites 
-- Order the results from highest to lowest avg_critic_score

SELECT year, avg_critic_score
FROM top_critic_years
EXCEPT
SELECT year, avg_critic_score
FROM top_critic_years_more_than_four_games
ORDER BY avg_critic_score DESC;

/* Years video game players loved */
-- Select year, an average of user_score, and a count of games released in a given year, aliased and rounded
-- Include only years with more than four reviewed games; group data by year
-- Order data by avg_user_score, and limit to ten results

SELECT year, ROUND(AVG(user_score), 2) AS avg_user_score, COUNT(game_sales.game) AS num_games
FROM game_sales
INNER JOIN reviews
ON game_sales.game = reviews.game
GROUP BY year
HAVING COUNT(game_sales.game) > 4
ORDER BY avg_user_score DESC
LIMIT 10;

/* Years that both players and critics loved */
-- Select the year results that appear on both tables

SELECT year
FROM top_critic_years_more_than_four_games
INTERSECT
SELECT year
FROM top_user_years_more_than_four_games

/* Sales in the best video game years */
-- Select year and sum of games_sold, aliased as total_games_sold; order results by total_games_sold descending
-- Filter game_sales based on whether each year is in the list returned in the previous task

SELECT year, SUM(games_sold) AS total_games_sold
FROM game_sales
WHERE year IN (
                SELECT year
                FROM top_critic_years_more_than_four_games
                INTERSECT
                SELECT year
                FROM top_user_years_more_than_four_games
)
GROUP BY year
ORDER BY total_games_sold DESC;