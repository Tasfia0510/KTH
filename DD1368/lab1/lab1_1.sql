SET search_path TO schema_lab12025, public;

CREATE TABLE IF NOT EXISTS users (
    userID        int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fullName      varchar(255) NOT NULL
);


CREATE TABLE IF NOT EXISTS student (
    userID          int NOT NULL,
    programme       varchar(255) NOT NULL, 
    PRIMARY KEY(userID),
    CONSTRAINT fk_students FOREIGN KEY(userID) REFERENCES users(userID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS staff (
    userID          	int NOT NULL, 
    department          varchar(4) NOT NULL CHECK (Department IN ('ABE', 'EECS', 'ITM', 'CBH', 'SCI')), 
    PRIMARY KEY(UserID),
    CONSTRAINT fk_staff FOREIGN KEY(userID) REFERENCES users(userID)
);


CREATE TABLE IF NOT EXISTS friendship (
    userID              int NOT NULL, 
    friendID            int NOT NULL, 
    PRIMARY KEY(userID, friendID),
    CONSTRAINT Check_friendship CHECK (userID <> friendID),   -- inte självrelation
    CONSTRAINT fk_Friendship_userID FOREIGN KEY(userID) REFERENCES users(userID)ON DELETE CASCADE,
    CONSTRAINT fk_friendship_friendID FOREIGN KEY(friendID) REFERENCES users(userID) ON DELETE CASCADE
);

CREATE UNIQUE INDEX Associative_friendship ON friendship (LEAST(userID, friendID), GREATEST(userID, friendID));

CREATE TABLE IF NOT EXISTS post (
    postID          int GENERATED ALWAYS AS IDENTITY PRIMARY KEY CHECK (postID >= 0),  
    userID          int NOT NULL, 
    title           varchar(255),
    uploadedAt      timestamp NOT NULL,
    place           varchar(255),
    contents        varchar(255), -- text
    CONSTRAINT fk_post_userID FOREIGN KEY(userID) REFERENCES users(userID)ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS postTags (
    postID      int NOT NULL, 
    tagName      varchar(8) NOT NULL CHECK (tagName IN ('crypto', 'studying', 'question', 'social')), 
    PRIMARY KEY(PostID, TagName),
    CONSTRAINT fk_postTags_postID FOREIGN KEY (postID) REFERENCES post(postID) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS postLike (
    userID      int NOT NULL,
    postID      int NOT NULL,
    likedAt   timestamp NOT NULL,
    PRIMARY KEY(userID, postID),
    CONSTRAINT fk_postLike_userID FOREIGN KEY(userID) REFERENCES users(userID) ON DELETE CASCADE,
    CONSTRAINT fk_postLike_postID FOREIGN KEY(postID) REFERENCES post(postID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS attachment (
    postID          int NOT NULL, 
    attachmentURL   varchar(255) NOT NULL,
    fileType        varchar(255) NOT NULL CHECK (fileType IN('Image', 'Video')),
    fileSize        int NOT NULL,
    PRIMARY KEY(postID, attachmentURL),
    CONSTRAINT fk_attachment_postID FOREIGN KEY(postID) REFERENCES post(postID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS events (
    eventID	    int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    userID      int NOT NULL,
    title       varchar(255) NOT NULL,
    place       varchar(255) NOT NULL,
    startDate   timestamp NOT NULL,
    endDate     timestamp NOT NULL,
    duration    int, 
    CONSTRAINT Check_Order_Of_events CHECK (endDate >= startDate), 
    CONSTRAINT fk_event FOREIGN KEY(userID) REFERENCES users(userID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS attendee (
    eventID     int NOT NULL,
    userID      int NOT NULL,
    PRIMARY KEY (userID, eventID),
    CONSTRAINT fk_attendee_eventID FOREIGN KEY(eventID) REFERENCES events(eventID) ON DELETE CASCADE, 
    CONSTRAINT fk_attendee_userID FOREIGN KEY(userID) REFERENCES users(userID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS subscriptions (
    subscriptionID  int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    userID          int NOT NULL, 
    dateOfPayment   timestamp NOT NULL,
    paymentMethod   varchar(255) NOT NULL CHECK(paymentMethod IN ('klarna', 'swish', 'card', 'bitcoin')), 
    expiryDate      timestamp NOT NULL, 
    CONSTRAINT fk_subscription_userID FOREIGN KEY(userID) REFERENCES users(userID) ON DELETE CASCADE
);