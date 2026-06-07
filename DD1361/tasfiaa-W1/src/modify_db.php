<?php
/**
 * I den här sidan ska användaren kunna modifiera varor i databasen. Lägga till ändra status etc...
 */
session_start();
require "functions.php";
$db = new SQLite3('../database/account_items.db');

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["lägg_till"])) {
    $productName = $_POST["productName"]; // hämta produkten vi skriver in 
    $userID = $_SESSION["userID"]; 

    $productID =  addProducts($productName, $db);
    addProductToList($userID, $productID, $db);

    // skicka tillbaka användaren till inköpslistan
    header("Location: generate_shopping_list.php"); 
    exit();
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modify List</title>
    <link
      rel="stylesheet"
      href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"
    />
 
</head>
<body>
    <div class = "container">
    <a href = "logout.php" style = "position:fixed; top:10px; right:10px;"> Logga ut</a>
        <h2> Här kan du ändra din inköpslista! <h2>
            <form method = "post">
                <label> Produkt namn </label>
                <input type = "text" name = "productName" required>
                <button type = "submit" name= "lägg_till" >  Lägg till  </button>
            </form>
    </div>
</body>
</html>