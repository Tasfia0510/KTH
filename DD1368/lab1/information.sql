INSERT INTO users (fullname) VALUES 
('Lars'),
('Tommy'),
('Elsa'),
('Tina'),
('Harry'),
('Daniel');

INSERT INTO staff (userID, department) VALUES 
(1, 'ABE'),
(2, 'EECS');


INSERT INTO student (userID, programme) VALUES
(3, 'Datateknik'),
(4, 'Samhällsbyggnad'),
(5, 'Fastighet och finans'),
(6, 'Biokemi');

INSERT INTO friendship (userID, friendID) VALUES
(1,2),
(1,4),
(2,5),
(3,5),
(3,6);

INSERT INTO post (userID, title, uploadedAt, place, contents) VALUES 
(1, 'Äntligen fixat canvas', NOW() ,'kth', 'allt ni behöver för att klara...'),
(2, 'Bästa kladdkaksreceptet', NOW() ,'hemma', 'snabbt och smidigt ...'),
(3, 'Rekommenderad matte-kanal', NOW() ,'kth', 'såhär klarar du alla mattekurser');

INSERT INTO attachment(postID, attachmentURL, fileType, fileSize) VALUES 
(2, 'https://example.com/kladdkaksrecept.jpg', 'Image', 5505033),
(3, 'https://example.com/lars.mp4', 'Video', 291021941);

INSERT INTO postTags (postID, tagName) VALUES 
(3, 'question'),    
(3, 'studying'),
(1, 'question');

INSERT INTO postLike (userID, postID, likedAt) VALUES 
(1,3, '2025-08-20 17:17:53'),
(2,3, '2025-08-19 17:17:53'),
(3,1, '2025-08-10 17:17:53'),
(4,1, '2025-08-17 17:17:53'),
(5,3, '2025-08-16 17:17:53'),
(5,2, '2025-08-16 17:17:53'),
(6,2, '2025-08-17 17:17:53');

INSERT INTO events (userID, title, place, startDate, endDate) VALUES
(3, 'studentsittning', 'meta', '2025-11-08 17:17:00', '2025-11-09 03:00:00');

INSERT INTO attendee (eventID, userID) VALUES 
(1, 5),
(1, 6);

INSERT INTO subscriptions (userID, dateOfPayment, paymentMethod, expiryDate) VALUES 
(1,'2025-08-20 17:17:53', 'swish', '2025-09-19 17:17:53'),
(2,'2025-08-20 22:15:03', 'bitcoin', '2025-09-19 22:15:03'),
(3,'2025-09-03 07:30:12', 'card', '2025-10-03 07:30:12'),
(4,'2025-09-10 16:17:23', 'swish', '2025-10-10 16:17:23'),
(5,'2025-10-02 12:23:02', 'klarna', '2025-11-01 12:23:02'),
(6,'2025-10-04 18:34:52', 'klarna', '2025-10-04 18:34:52');

