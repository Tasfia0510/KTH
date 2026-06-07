CREATE TABLE users (
    userID INTEGER PRIMARY KEY,
    username VARCHAR NOT NULL UNIQUE,
    passwordHash VARCHAR NOT NULL,
    user_active INTEGER DEFAULT 0
);

CREATE TABLE products (
    productID INTEGER PRIMARY KEY,
    productName VARCHAR NOT NULL
);

CREATE TABLE purchase_history (
    purchaseID INTEGER PRIMARY KEY,
    userID INTEGER NOT NULL,
    purchaseDate DATE NOT NULL,
    FOREIGN KEY (userID) REFERENCES users(userID)
);

CREATE TABLE shopping_list (
    listID INTEGER PRIMARY KEY,
    purchaseID INTEGER NOT NULL,
    productID INTEGER NOT NULL,
    FOREIGN KEY (purchaseID) REFERENCES purchase_history(purchaseID),
    FOREIGN KEY (productID) REFERENCES products(productID)
);

CREATE TABLE active_list (
    userID INTEGER,
    productID INTEGER, 
    FOREIGN KEY (userID) REFERENCES users(userID), 
    FOREIGN KEY (productID) REFERENCES products(productID)
);

CREATE TABLE replacement (
    replacementID INTEGER PRIMARY KEY,
    productA_ID INTEGER NOT NULL,
    productB_ID INTEGER NOT NULL,
    FOREIGN KEY (productA_ID) REFERENCES products(productID),
    FOREIGN KEY (productB_ID) REFERENCES products(productID)
);
