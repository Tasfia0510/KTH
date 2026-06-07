-- ASSIGNMENT 1
SELECT
	post.title,
	string_agg(posttag.tag, ',') AS tags

FROM
	post

INNER JOIN
	posttag ON post.postid = posttag.postid

GROUP BY 
	posttag.postid, post.title

ORDER BY
	post.title;

-- ASSIGNMENT 2
SELECT		 
	postid,
	title,
	rank 
FROM  (										
	SELECT
		p.postid,
		p.title,
		Rank() OVER (  order by count(l.postid) DESC  ) AS rank 

	FROM
		post p 

	INNER JOIN 
		posttag pt ON p.postid = pt.postid -- kopplar post och tags (i och med att tags inte finns med i post)

	INNER JOIN 
		likes l ON p.postid = l.postid	-- likes och post (inga null likes)

	WHERE
		pt.tag = '#leadership'
	
	GROUP BY 
		p.postid, p.title
	)
WHERE
	rank <=5 

ORDER BY
	rank ASC, title ASC; -- rank prioriteras före titel 

-- ASSIGNMENT 3

WITH weeks AS(
	SELECT generate_series(1,30) AS week_number
	),
	subscription_week AS(
		SELECT
			s.userid,
			s.date AS dateofsub,
			date_part('week', s.date) AS week
		FROM
			subscription s
	),
	
	new_subscription AS(
		SELECT
			s.userid,	
			s.week
		FROM
			subscription_week s
	
		LEFT JOIN
		 	subscription_week formersub
 			ON s.userid= formersub.userid
			AND s.dateofsub  > formersub.dateofsub
		WHERE
			formersub.userid IS NULL
),
	former_subscription AS(
		SELECT
			s.userid,	
			s.week
		FROM
			subscription_week s

		INNER JOIN
 			subscription_week formersub
			ON s.userid= formersub.userid
			AND s.dateofsub  > formersub.dateofsub
),
	weekly_post_activity AS(
		SELECT
			date_part('week', p.date) AS postweek,
			COUNT(p.postid) AS postactivitycount
		FROM
			post p
		GROUP BY 
			date_part('week', p.date)
)
SELECT
	w.week_number AS week,
	COUNT(DISTINCT ns.userid) AS new_customers,
	COUNT(DISTINCT fs.userid) AS kept_customers,
	COALESCE(wa.postactivitycount, 0) AS activity

FROM 
	weeks w
LEFT JOIN
	new_subscription ns ON ns.week = w.week_number
LEFT JOIN
	former_subscription fs ON fs.week = w.week_number
LEFT JOIN
	weekly_post_activity wa ON wa.postweek = w.week_number
GROUP BY 
	w.week_number,
	wa.postactivitycount
ORDER BY
w.week_number;	

-- ASSIGNMENT 4
WITH january_registrations AS (
	SELECT 
		u.userid, 
		u.name,
		MIN(s.date) AS registration_date	-- ger det senaste reg datumet i en ny kolumn 
	
	FROM
		users u 

	INNER JOIN subscription s 			-- users + subscriptions, inner join ger registrerade users (annars null)
	ON u.userid = s.userid

	GROUP BY
		u.userid, 				-- slår ihop, inga dupes
		u.name
		
)

SELECT
	j.name,
	EVERY (f.friendid IS NOT NULL) AS has_friend,	-- every function 
	j.registration_date 

FROM 
january_registrations j 

LEFT JOIN friend f					-- left join så att vi kan få null för friendid (alltså har inga vänner)
	ON j.userid = f.userid 

WHERE date_part('month', j.registration_date) = 1

GROUP BY 
	j.userid,
	j.name, 
	j.registration_date

ORDER BY 
		j.name;

-- ASSIGNMENT 5
WITH RECURSIVE friend_chain AS(
    -- anchor member vi vill börja med Anas (userid 20)
    SELECT 
	f.userid AS userid,
	f.friendid AS friendid

   FROM 
	friend  f
   WHERE 
	f.userid = 20

    UNION ALL

    -- recursive term, hitta vänner till vänner
    SELECT 
	 fc.friendid AS userid,
	 f.friendid AS friendid

    FROM 
	friend_chain fc 

    LEFT JOIN 
	friend f ON fc.friendid = f.userid
WHERE 
	fc.friendid IS NOT NULL

)

SELECT 
	u.name AS name,
	fc.userid AS user_id,
	fc.friendid AS friend_id
FROM
	friend_chain fc

INNER JOIN 
	users u ON fc.userid= u.userid;

-- P+
WITH march_posts AS (
	SELECT
		p.userid,
		p.postid,
		COUNT(likes.postid) AS likes_count

	FROM
		post p
	
	LEFT JOIN likes ON likes.postid = p.postid

	WHERE date_part('month', p.date) = 3

	GROUP BY 
		p.userid,
		p.postid 

), 

total_likes AS (
	SELECT
		userid, 
		SUM(likes_count) AS total_count

	FROM 
		march_posts
	GROUP BY 
		userid 
)

	SELECT
		u.name, 
		(total_likes.total_count) >= 50 AS received_likes

	FROM 
		total_likes

	INNER JOIN users u ON u.userid = total_likes.userid

	ORDER BY
		u.name; 

