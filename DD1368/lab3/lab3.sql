-- Assignment 1 

-- Part 1: länder med minst antal grannländer
WITH neighbors AS(
    SELECT 
	c.name,
	COUNT(*) AS num_neighbors  
	
    FROM 
        country c

    INNER JOIN
        borders b ON country1 = c.code					-- code är gemensamt i country + borders
                  OR country2 = c.code

    GROUP BY 
	c.name
),

min_counter AS (
SELECT 
	MIN(num_neighbors) AS num 
FROM 
	neighbors 
)

SELECT
	n.name, 
	m.num 

FROM
	neighbors n 

INNER JOIN 
	min_counter m ON n.num_neighbors = m.num			-- alla grannländer blir minsta grannländer
	
ORDER BY
	n.name; 

-- Part 2: språk och antal som pratar det språket 
WITH speakers AS(							-- räknar talare i varje land 						

SELECT
	s.language,
	(s.percentage / 100)* c.population AS total_speakers

FROM 
	spoken s

INNER JOIN 
	country c ON s.country = c.code	

WHERE
	s.percentage IS NOT NULL
)

SELECT
	language,
	SUM (total_speakers):: int AS numberspeakers			
	
FROM
	speakers

GROUP BY
	language

ORDER BY
	numberspeakers DESC;

-- Part 3: räkna två länders gdp + ratio 

-- För ratio = gdp1 / gdp2
SELECT
	b.country1 AS country1,
	e1.gdp AS gdp1, 
	b.country2 AS country2, 
	e2.gdp AS gdp2,
	(e1.gdp / e2.gdp):: int AS ratio
	
FROM 
	borders b

INNER JOIN 
	economy e1 ON b.country1 = e1.country

INNER JOIN 
	economy e2 ON b.country2 = e2.country

WHERE
	e1.gdp IS NOT NULL 
	AND e2.gdp IS NOT NULL

UNION ALL 

-- För ratio = gdp2 / gdp1
SELECT
	b.country1 AS country1,
	e1.gdp AS gdp1, 
	b.country2 AS country2, 
	e2.gdp AS gdp2,
	(e2.gdp / e1.gdp):: int AS ratio
	
FROM 
	borders b

INNER JOIN 
	economy e1 ON b.country1 = e1.country

INNER JOIN 
	economy e2 ON b.country2 = e2.country

WHERE
	e1.gdp IS NOT NULL 
	AND e2.gdp IS NOT NULL
	
ORDER BY
	ratio DESC;

-- P+ 1
--  Lösning 1 
WITH RECURSIVE countries_crossed AS (
	-- basecase, börja från sverige
	SELECT 
		c.code, 
		0 AS crossed_border

	FROM 
		country c  

	WHERE 
		c.code = 'S'
	
	UNION 

	-- recursive where it goes both directions
	
	SELECT
		next_country.to_country, 
		cc.crossed_border + 1

	FROM
		countries_crossed cc 
	
	INNER JOIN (
		SELECT 
			b.country1 AS from_country,
			b.country2 AS to_country
		FROM 
			borders b 

		UNION 

		SELECT 
			b.country2 AS from_country,
			b.country1 AS to_country
		FROM
			borders b
	
		) AS next_country ON next_country.from_country = cc.code
		
	WHERE
		cc.crossed_border < 5
)

SELECT
	c.code,
	c.name, 
	min(crossed_border) AS min 
FROM 
	countries_crossed cc 

INNER JOIN 
	country c ON c.code = cc.code

WHERE 
	cc.code != 'S'

GROUP BY 
	c.code
ORDER BY 
	min;

-- LYCKAS MEN KANSKE LITE SVÅR, LÖSNING 2 
WITH RECURSIVE countries_crossed AS (
	-- basecase, börja från sverige
	SELECT 
		code, 
		0 AS crossed_border

	FROM 
		country c  

	WHERE 
		code = 'S'
	
	UNION 

	-- recursive part
	
	SELECT
		COALESCE(
           	NULLIF(b.country1, cc.code),
           	NULLIF(b.country2, cc.code))::varchar(4) AS code,
		cc.crossed_border + 1

	FROM
		countries_crossed cc 
	
	INNER JOIN 
		borders b ON b.country1 = cc.code
		OR b.country2 = cc.code

	WHERE
		cc.crossed_border < 5

)

SELECT
	c.code,
	c.name, 
	min(crossed_border) AS min 
FROM 
	countries_crossed cc 

INNER JOIN 
	country c ON c.code = cc.code

WHERE 
	cc.code != 'S'

GROUP BY 
	c.code,
	c.name
ORDER BY 
	min;

-- P+: Part 2 

WITH RECURSIVE path_for_river AS (
-- base case: börja från våra main rivers 
SELECT
	r.name AS current, 
	r.name::text AS path, 		-- själva kedjan i början 
	r.name AS root, 
	r.length AS total_length,
	1 AS numrivers	-- antal rivers börjar på 1  
	
FROM
	river r 

WHERE 
	r.name IN ('Nile', 'Amazonas', 'Yangtze', 'Rhein', 'Donau', 'Mississippi')

UNION 

-- rekursivt: hitta alla tributaries 
SELECT
	r.name AS current,			-- child river 
	pr.path || '-' || r.name AS path,
	pr.root,
	pr.total_length + r.length AS total_length, 
	pr.numrivers + 1 AS numrivers
FROM
	river r

INNER JOIN 
	path_for_river pr ON r.river = pr.current 	-- joinar child river i kedjan 

),

-- väljer endast branches som är längst

max_length AS (
SELECT 
	p.root,
	MAX(numrivers) AS max_rivers

FROM path_for_river p

GROUP BY 
	p.root
)

SELECT 
	RANK() OVER (ORDER BY p.numrivers) AS rank, 
	p.path, 
	p.numrivers,
	p.total_length

FROM	path_for_river p

INNER JOIN max_length m ON p.root = m.root AND p.numrivers = m.max_rivers 

ORDER BY
	rank, p.total_length DESC; 
	


