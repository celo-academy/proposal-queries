WITH sage_votes AS (
    SELECT dvv.topic_id
    FROM discourse_voting_votes dvv
    JOIN group_users gu ON dvv.user_id = gu.user_id
    JOIN groups g ON gu.group_id = g.id
    WHERE g.name = 'Sage'
),
sage_users AS (
    SELECT gu.user_id
    FROM group_users gu
    JOIN groups g ON gu.group_id = g.id
    WHERE g.name = 'Sage'
),
vote_counts AS (
    SELECT topic_id, COUNT(topic_id) AS "Number of Votes"
    FROM sage_votes
    GROUP BY topic_id
),
ranked_topics AS (
    SELECT 
        topics.title AS "Proposal Title", 
        CONCAT('https://celo.academy/t/', topics.slug, '/', topics.id) AS "Link",
        topics.excerpt AS "Topic Description",
        users.username AS "Topic Owner",
        vote_counts."Number of Votes",
        ROW_NUMBER() OVER (PARTITION BY topics.user_id ORDER BY vote_counts."Number of Votes" DESC) as rn
    FROM 
        topics 
    JOIN 
        vote_counts ON topics.id = vote_counts.topic_id
    JOIN
        users ON topics.user_id = users.id
    WHERE
        topics.user_id IN (SELECT user_id FROM sage_users)
)

SELECT 
    "Proposal Title",
    "Link",
    "Topic Description",
    "Topic Owner",
    "Number of Votes"
FROM
    ranked_topics
WHERE
    rn = 1
ORDER BY
    "Number of Votes" DESC
LIMIT 15
