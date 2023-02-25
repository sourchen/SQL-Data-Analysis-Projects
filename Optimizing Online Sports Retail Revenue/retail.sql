/* 1. Counting missing values */

-- Count all columns as total_rows
-- Count the number of non-missing entries for description, listing_price, and last_visited
-- Join info, finance, and traffic

SELECT COUNT(*) AS total_rows, 
    COUNT(description) AS count_description, 
    COUNT(listing_price) AS count_listing_price,
    COUNT(last_visited) AS count_last_visited
FROM info 
JOIN finance 
    ON info.product_id = finance.product_id
JOIN traffic 
    ON info.product_id = traffic.product_id

/* 2. Nike vs Adidas pricing */

-- Select the brand, listing_price as an integer, and a count of all products in finance 
-- Join brands to finance on product_id
-- Filter for products with a listing_price more than zero
-- Aggregate results by brand and listing_price, and sort the results by listing_price in descending order

SELECT brand, CAST(listing_price AS int), COUNT(finance.product_id)
FROM info
JOIN brands
    ON info.product_id = brands.product_id
JOIN finance
    ON info.product_id = finance.product_id
WHERE listing_price > 0
GROUP BY brand, listing_price
ORDER BY listing_price DESC;

/* 3. Labeling price ranges */

-- Select the brand, a count of all products in the finance table, and total revenue
-- Create four labels for products based on their price range, aliasing as price_category
-- Join brands to finance on product_id and filter out products missing a value for brand
-- Group results by brand and price_category, sort by total_revenue

SELECT 
    brandS.brand,
    COUNT(finance.product_id), 
    SUM(revenue) AS total_revenue,
    CASE  
        WHEN listing_price < 42 THEN 'Budget'
        WHEN (listing_price >= 42 AND listing_price < 74) THEN 'Average'
        WHEN (listing_price >= 74 AND listing_price < 129) THEN 'Expensive'
        WHEN listing_price > 129 THEN 'Elite'
    END AS price_category
FROM finance
JOIN brands 
    ON finance.product_id = brands.product_id
WHERE brands.brand IS NOT NULL
GROUP BY brands.brand, price_category
ORDER BY total_revenue DESC;

/* 4. Average discount by brand */

-- Select brand and average_discount as a percentage
-- Join brands to finance on product_id
-- Aggregate by brand
-- Filter for products without missing values for brand

SELECT brands.brand, AVG(discount)*100 AS average_discount
FROM brands
INNER JOIN finance
    ON brands.product_id = finance.product_id
GROUP BY brands.brand
HAVING brands.brand IS NOT NULL

/* 5. Correlation between revenue and reviews */

-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id

SELECT corr(finance.revenue, reviews.reviews) AS review_revenue_corr
FROM reviews
INNER JOIN finance
    ON reviews.product_id = finance.product_id

/* 6. Ratings and reviews by product description length */

-- Calculate description_length
-- Convert rating to a numeric data type and calculate average_rating
-- Join info to reviews on product_id and group the results by description_length
-- Filter for products without missing values for description, and sort results by description_lengths

SELECT TRUNC(LENGTH(info.description), -2) AS description_length,
        ROUND(AVG(rating::numeric), 2) AS average_rating
FROM info
INNER JOIN reviews
    ON info.product_id = reviews.product_id
WHERE info.description IS NOT NULL
GROUP BY description_length
ORDER BY description_length;

/* 7. Reviews by month and brand */

-- Select brand, month from last_visited, and a count of all products in reviews aliased as num_reviews
-- Join traffic with reviews and brands on product_id
-- Group by brand and month, filtering out missing values for brand and month
-- Order the results by brand and month

SELECT brand, 
    DATE_PART('month', last_visited) AS month,
    COUNT(reviews.product_id) AS num_reviews
FROM traffic
INNER JOIN reviews
    ON traffic.product_id = reviews.product_id
INNER JOIN brands
    ON traffic.product_id = brands.product_id
GROUP BY brand, month
HAVING brand IS NOT NULL 
    AND DATE_PART('month', last_visited) IS NOT NULL
ORDER BY brand, month

/* 8. Footwear product performance */

-- Create the footwear CTE, containing description and revenue
-- Filter footwear for products with a description containing %shoe%, %trainer, or %foot%
-- Also filter for products that are not missing values for description
-- Calculate the number of products and median revenue for footwear products

WITH footwear AS
(
    SELECT info.description, finance.revenue
    FROM info 
    INNER JOIN finance
        ON info.product_id = finance.product_id
    WHERE (
        info.description ILIKE '%shoe%'
         OR info.description ILIKE '%trainer%'
         OR info.description ILIKE '%foot%'
        AND info.description IS NOT NULL)
)

SELECT COUNT(*) AS num_footwear_products,
        percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS median_footwear_revenue
FROM footwear;

/* 9. Clothing product performance */

-- Copy the footwear CTE from the previous task
-- Calculate the number of products in info and median revenue from finance
-- Inner join info with finance on product_id
-- Filter the selection for products with a description not in footwear

WITH footwear AS
(
    SELECT info.description, finance.revenue
    FROM info 
    INNER JOIN finance
        ON info.product_id = finance.product_id
    WHERE (
        info.description ILIKE '%shoe%'
         OR info.description ILIKE '%trainer%'
         OR info.description ILIKE '%foot%'
        AND info.description IS NOT NULL)
)

SELECT COUNT(*) AS num_clothing_products,
    percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS median_clothing_revenue
FROM info 
INNER JOIN finance
    ON info.product_id = finance.product_id 
WHERE info.description NOT IN(SELECT description FROM footwear)
