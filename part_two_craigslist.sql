DROP DATABASE IF EXISTS craigslist;

CREATE DATABASE craigslist;

\c craigslist

CREATE TABLE Regions (
    region_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE       -- <-- NOT NULL! --
);

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    preferred_region_id INT REFERENCES Regions(region_id)
);

CREATE TABLE Locations (
    location_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    region_id INT NOT NULL REFERENCES Regions(region_id)
);

CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE Posts (
    post_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    user_id INT NOT NULL REFERENCES Users(user_id),
    location_id INT REFERENCES Locations(location_id),
    region_id INT REFERENCES Regions(region_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PostCategories (
    post_id INT REFERENCES Posts(post_id) ON DELETE CASCADE,
    category_id INT REFERENCES Categories(category_id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, category_id)
);

-- It was suggested that I add Indexes
CREATE INDEX idx_posts_region ON Posts(region_id);
CREATE INDEX idx_posts_user ON Posts(user_id);
CREATE INDEX idx_postcategories_category ON PostCategories(category_id);


-- It was suggested that I add Constraints
ALTER TABLE Users ADD CONSTRAINT email_format CHECK (email LIKE '%@%.%');
ALTER TABLE Posts ADD CONSTRAINT fk_post_region CHECK (region_id IS NOT NULL);


INSERT INTO Regions (name)
VALUES 
('San Francisco'),
('Seattle'),
('Atlanta'),
('New York');

INSERT INTO Users (username, email, preferred_region_id)
VALUES
('alice', 'alice@example.com', 1),      -- prefers San Francisco
('bob', 'bob@example.com', 2),          -- prefers Seattle
('charlie', 'charlie@example.com', 1),  -- prefers San Francisco
('diana', 'diana@example.com', 3);      -- prefers Atlanta


INSERT INTO Locations (name, region_id)
VALUES
('Mission District', 1),
('Downtown', 1),
('Capitol Hill', 2),
('Buckhead', 3),
('Manhattan', 4);


INSERT INTO Categories (name)
VALUES
('Housing'),
('For Sale'),
('Jobs'),
('Services'),
('Community');


INSERT INTO Posts (title, description, user_id, location_id, region_id)
VALUES
('Sunny 1BR Apartment', 'Spacious 1-bedroom with balcony and parking.', 1, 1, 1),
('Used iPhone 14 Pro', 'Lightly used, great condition, includes case.', 2, 3, 2),
('Frontend Developer Needed', 'Looking for React devs for a startup.', 3, 2, 1),
('Plumbing Services', 'Fast and reliable 24/7 plumbing repairs.', 4, 4, 3),
('Community Cleanup Event', 'Join us this weekend to clean up Golden Gate Park.', 1, 2, 1);


INSERT INTO PostCategories (post_id, category_id)
VALUES
(1, 1),  -- Housing
(2, 2),  -- For Sale
(3, 3),  -- Jobs
(4, 4),  -- Services
(5, 5);  -- Community


SELECT p.title, p.description, u.username, r.name AS region, c.name AS category
FROM Posts p
    JOIN Users u ON p.user_id = u.user_id
    JOIN Regions r ON p.region_id = r.region_id
    JOIN PostCategories pc ON p.post_id = pc.post_id
    JOIN Categories c ON pc.category_id = c.category_id
WHERE r.name = 'San Francisco' AND c.name = 'Housing';


-- It was suggested that I add more queries:
SELECT p.title, r.name AS region
FROM Posts p
    JOIN Regions r ON p.region_id = r.region_id
WHERE r.name = 'Seattle';

SELECT p.title, p.description, r.name AS region
FROM Posts p
    JOIN Users u ON p.user_id = u.user_id
    JOIN Regions r ON p.region_id = r.region_id
WHERE u.username = 'alice';

SELECT p.title, STRING_AGG(c.name, ', ') AS categories
FROM Posts p
    JOIN PostCategories pc ON p.post_id = pc.post_id
    JOIN Categories c ON pc.category_id = c.category_id
GROUP BY p.title;
