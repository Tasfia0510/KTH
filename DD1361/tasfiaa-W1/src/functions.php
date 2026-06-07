<?php
//Här ska du lägga till flera funktioner 

// Går till mappen där account_items.db finns 
//$db = new PDO("sqlite:" . __DIR__ . "/../database/account_items.db");

//Observera att följande funktion är sårbar för sql-injection och behöver förbättras
function selectPwd($username){
    // Öppna SQLite-databasen
    $db = new SQLite3('../database/account_items.db');

    // Förbered SQL-frågan
    $sql = $db->prepare("SELECT password FROM users WHERE username = :username");
    //bind värde till parameter
    $sql-> bindValue(':username', $username, SQLITE3_TEXT); 

    // Utför frågan
    $result = $sql->execute();

    // Hämta raden från resultatet
    $row = $result->fetchArray(SQLITE3_ASSOC);

    // Stäng databasanslutningen
    $db->close();
    // Returnera resultatet (kan vara null om användarnamnet inte hittades)
    return $row;

}

//uppdatera om user är aktiv/inloggad
function activeUser($userID, $db) {
    $update= $db->prepare("UPDATE users SET user_active =1 WHERE userID= :userID");
    $update->bindValue(':userID', $userID, SQLITE3_INTEGER);
    $update->execute();
}

//uppdatera om user inte längre är aktiv/inloggad
function notActiveUser($userID, $db) {
    $update= $db->prepare("UPDATE users SET user_active =0 WHERE userID= :userID");
    $update->bindValue(':userID', $userID, SQLITE3_INTEGER);
    $update->execute();
}


// hämtar alla produkter
// hämtar alla produkter
function getAllProducts($db) {
    $getProducts = "SELECT productID, productName FROM products";
    $result = $db->query($getProducts);                                   
    $products = [];
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $products[] = $row;
    }
    return $products;
}

// hämtar produkter som har köpts
function getBoughtProducts($db) {
    $getProducts = "SELECT p.productID, p.productName FROM products p JOIN shopping_list sl ON sl.productID = p.productID WHERE sl.productID IS NOT NULL;";
    $result = $db->query($getProducts);                                   
    $products = [];
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $products[] = $row;
    }
    return $products;
}

function addProducts($productName, $db) {
    // hantera dubletter 
    $dubble = $db->prepare("SELECT productID FROM products WHERE productName= :productName");
    $dubble->bindValue(':productName', $productName, SQLITE3_TEXT);
    $result = $dubble->execute();
    $found = $result -> fetchArray(SQLITE3_ASSOC);

    //om dublett ge bara id istället
    if ($found) {
        return $found['productID'];
    }
    // lägga till varor i databasen kopplat till inloggad användare
    $addProduct = $db->prepare("INSERT INTO products (productName) VALUES (:productName)");
    //bind värde till parameter
    $addProduct -> bindValue(":productName", $productName, SQLITE3_TEXT);
    // utför frågan
    $addProduct->execute(); 
    return $db->lastInsertRowID();
}

//ta bort permanent från produkter
function deleteProduct($userID, $productID, $db) {
    // ta bort den varan och all dess köp historik (rekommendation)
    $deleteProduct = $db->prepare("DELETE FROM products WHERE productID = :productID"); 
    //bind värde till parameter
    $deleteProduct -> bindValue(":productID",$productID, SQLITE3_INTEGER);
    $deleteProduct->execute(); 

    // ta bort som tidigare inköp så den försvinner helt o hållet!
    $deleteShopping = $db->prepare("DELETE FROM shopping_list WHERE productID = :productID "); 
    //bind värde till parameter
    $deleteShopping -> bindValue(":productID",$productID, SQLITE3_INTEGER);
    $deleteShopping->execute(); 
}

//lägg till produkt till inköpslistan
function addProductToList($userID, $productID, $db) {
    // lägga till i vår egna lisa
    $add = $db->prepare('INSERT INTO active_list (userID, productID) VALUES (:userID, :productID)');
    $add->bindValue(':userID', $userID, SQLITE3_INTEGER);
    $add->bindValue(':productID', $productID, SQLITE3_INTEGER);
    $add->execute();
}

// ta bort produkt från inköpslistan
function deleteProductFromActiveList($userID, $productID, $db) {
    $delete = $db->prepare('DELETE FROM active_list WHERE userID = :userID AND productID = :productID');
    $delete->bindValue(':userID', $userID, SQLITE3_INTEGER);
    $delete->bindValue(':productID', $productID, SQLITE3_INTEGER);
    $delete->execute();
}

//hämta alla produkter från den aktiva listan
function getProductsFromActive($userID, $db) {
    $getListProducts = $db->prepare("SELECT p.productID, p.productName FROM active_list al JOIN products p ON al.productID = p.productID WHERE al.userID = :userID");
    $getListProducts-> bindValue(':userID', $userID, SQLITE3_INTEGER);
    $result = $getListProducts -> execute();
    $activeProducts = [];
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $activeProducts[] = $row;
    };
    return $activeProducts;
}

// få rekommenderad lista
// data flow:
    // 1. programmet hämtar alla produkter
    // 2. tittar på varje produkt (en)
    // 3. hämtar användarens köp historik för varje produkt (koppla purchase_history och shopping_list)
    // 4. räknar ut genomsnitt dagar mellan köpen
    // 5. räknar nästa förväntade köpdatum och jämförs med dagens datum 
    // 6. om det har nått eller passerat köpdatumet läggs det till! 
function getRecommendedProducts($userID, $db) {

    $recommended = [];
    $today = new DateTime();

    $getProducts = $db->prepare("SELECT * FROM products"); 
    $result = $getProducts->execute();                                  
    $products = [];
    while($product = $result->fetchArray(SQLITE3_ASSOC)) {
        $getHistory = $db->prepare("SELECT purchaseDate
                                    FROM purchase_history ph
                                    JOIN shopping_list sl ON ph.purchaseID = sl.purchaseID
                                    WHERE ph.userID = :userID
                                    AND sl.productID = :productID
                                    ORDER BY purchaseDate ASC");
        $getHistory->bindValue(':userID', $userID, SQLITE3_INTEGER);
        $getHistory->bindValue(':productID', $product['productID'], SQLITE3_INTEGER);
        $historyResult = $getHistory->execute();

        $dates = [];
        while($row = $historyResult->fetchArray(SQLITE3_ASSOC)) {
            $dates[] = $row['purchaseDate'];
        }

        // fall 1: 0 eller 1 köp av en produkt, då kan man inte räkna genomsnitt
        if (count ($dates) < 2) {
            continue;
        }

        // räknar antalet dagar mellan köp av samma produkt
        // t.ex datum 01, 05, 08, 13 ger 4+3+5 så totalDays = 12
        $totalDays = 0;
        for ($i = 1; $i < count($dates); $i++) {
            $date1 = new DateTime($dates[$i - 1]); // föregående datum
            $date2 = new DateTime($dates[$i]); // nuvarande datum 
            $totalDays += $date1->diff($date2)->days; // ta skillnaden och lägg till i days
        }

        // dela med antal intervall (alltid ett mindre än antal datum)
        // t.ex 4 datum, 3 intervall ger 12/3 som ger 4 dagar i genomsnitt
        $avgInterval = $totalDays / (count($dates)-1);

        if ($avgInterval <= 0) {
            continue;
        }

        // senaste köpdatum + genomsnitt intervall som vi räknat ut = nästa köp
        $nextDate = new DateTime($dates[count($dates) - 1]);
        $nextDate->modify("+{$avgInterval} days");

        if ($today >= $nextDate) {
            $recommended[] = $product;
        }
    }
    return $recommended;
}
//lägga till produkter i historiken
function addPurchase($userID, $db, $date = null) {
    // om vi inte anger nytt värde så är det här standard
    if($date === null ) {
        $date = date('Y-m-d');
    }

    $purchase = $db->prepare("INSERT INTO purchase_history(userID, purchaseDate ) VALUES (:userID, :purchaseDate)");
    $purchase-> bindValue(':userID', $userID, SQLITE3_INTEGER);
    $purchase-> bindValue(':purchaseDate', $date, SQLITE3_TEXT);
    $purchase -> execute();
    return $db->lastInsertRowID();
}

//spara activelist i shoppinglist
function saveShoppingList($purchaseID, $userID, $db) {
    $activeProducts = getProductsFromActive($userID, $db);

    $i = 0;
    while($i < count($activeProducts)) {
        $save = $db->prepare('INSERT INTO shopping_list(purchaseID, productID) VALUES (:purchaseID, :productID)');
        $save->bindValue(':purchaseID', $purchaseID, SQLITE3_INTEGER);
        $save->bindValue(':productID', $activeProducts[$i] ['productID'], SQLITE3_INTEGER);
        $save->execute();
        $i++;
    }
}

//töm active_list 
function emptyActiveList($userID, $db) {
    $empty = $db->prepare("DELETE FROM active_list WHERE userID = :userID");
    $empty-> bindValue(':userID', $userID, SQLITE3_INTEGER);
    $empty -> execute();
}

// lägger till en replacement
function addReplacement($productA_ID, $productB_ID, $db) {
    $replacement = $db->prepare('INSERT INTO replacement (productA_ID, productB_ID) VALUES (:productA_ID, :productB_ID)');
    $replacement->bindValue(':productA_ID', $productA_ID, SQLITE3_INTEGER);
    $replacement->bindValue(':productB_ID', $productB_ID, SQLITE3_INTEGER);
    $replacement->execute();
}

//hämta produktnamn
//function getProductName($productID, $db) {
  // $getProduct = "SELECT productName FROM products WHERE productID = :productID";
//    $getProduct->bindValue(':productID', $productID, SQLITE3_INTEGER);
//    $result = $getProduct->execute(); 
 //   return $result ->fetchArray(SQLITE3_ASSOC);                         
//}

?>

