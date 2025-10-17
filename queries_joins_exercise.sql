-- 1 Join the two tables so that every column and record appears, regardless of if there is not an owner_id . --
SELECT *
FROM owners o 
FULL OUTER JOIN vehicles v
ON o.id = v.owner_id;


-- 2 Count the number of cars for each owner. Display the owners first_name , last_name and count of vehicles. --
-- The first_name should be ordered in ascending order. --
SELECT first_name, last_name, COUNT(owner_id) 
FROM owners o 
JOIN vehicles v on o.id = v.owner_id 
GROUP BY first_name, last_name
ORDER BY first_name;


-- 3 Count the number of cars for each owner and display the average price for each of the cars as integers. -- 
-- Display the owners first_name , last_name, average price and count of vehicles. The first_name should be -- 
-- ordered in descending order. Only display results with more than one vehicle and an average price greater -- 
-- than 10000. --
SELECT first_name, last_name, ROUND(AVG(price)) AS average_price, COUNT(owner_id)
FROM owners o 
JOIN vehicles v ON o.id = v.owner_id 
GROUP BY o.id, first_name, last_name                        -- <-- just in case names are the same, I added o.id --
HAVING COUNT(owner_id) > 1 AND ROUND(AVG(price)) > 10000
ORDER BY first_name DESC, last_name DESC;                   -- <-- sort last_name too --

