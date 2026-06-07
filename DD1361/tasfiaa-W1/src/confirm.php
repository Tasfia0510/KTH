<?php
session_start();

include 'functions.php';

// Går till mappen där account_items.db finns 
$userID = $_SESSION['userID'];
$db = new SQLite3('../database/account_items.db');

$allProducts = getAllProducts($db);
$activeProducts = getProductsFromActive($userID, $db);

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['bekräfta'])) {
    // lägg in i purchase_history 
    //testfall avkommentera en i taget för att skapa ett nytt köp för respektive datum
   // addPurchase($userID, $db, '2024-01-01');
    //addPurchase($userID, $db, '2024-01-05');
    //addPurchase($userID, $db, '2024-01-08');
    // addPurchase($userID, $db, '2024-01-13');

    $purchase = addPurchase($userID, $db);
    // spara över allting från active_list in till shopping_list
    saveShoppingList($purchase, $userID, $db);

    // spara replacements genom att först kolla om användaren har valt någon i dropdown
    if (isset($_POST['replacement'])) {
    foreach ($_POST['replacement'] as $productA_ID => $productB_ID) {

        if (!empty($productB_ID) && $productA_ID != $productB_ID) {

            addReplacement($productA_ID, $productB_ID, $db);

            $update = $db->prepare("
                UPDATE shopping_list
                SET productID = :productB
                WHERE purchaseID = :purchaseID
                AND productID = :productA
            ");

            $update->bindValue(':productA', $productA_ID, SQLITE3_INTEGER);
            $update->bindValue(':productB', $productB_ID, SQLITE3_INTEGER);
            $update->bindValue(':purchaseID', $purchase, SQLITE3_INTEGER);
            $update->execute();
        }
    }
}

    //töm active_list så den är tom för nästa gången användaren loggar in
    emptyActiveList($userID, $db);

    // vi får kanske ändra till det här till att användaren automatiskt loggar ut
    header("Location: thanks.php");
    exit();
}

//lägg till direkt 
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["lägg_till_direkt"])) {
    $productName = $_POST["productName"]; // hämta produkten vi skriver in 
    $userID = $_SESSION["userID"]; 

    $productID =  addProducts($productName, $db);
    addProductToList($userID, $productID, $db);

    // låt användaren vara kvar
    header("Location: confirm.php"); 
    exit();
}

?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bekräfta inköpslistan</title>
</head>
<body>
    <h1>Bekräfta din inköpslista</h1>
    <br>
    <?php  if(empty($activeProducts)):?>
        <p> Tom inköpslista :/<p>
    <?php else: ?> 
    <form method="POST">   
        <?php $i=0; while ($i < count($activeProducts)): ?>
            <div style="display: flex; align-times: center; gap: 12px; margin-bottom: 10px;">
                <span>
                    <?= htmlspecialchars($activeProducts[$i]['productName']) ?>
                </span>Ersätt med:</span>

                <select name="replacement[<?= $activeProducts[$i]['productID'] ?>]">
                    <option value="">Välj ersättning</option>
                    <?php foreach ($allProducts as $product): ?>
                        <option value="<?= $product['productID'] ?>">
                            <?= htmlspecialchars($product['productName']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
        <?php $i++; endwhile ?>
    <?php endif; ?>
   
    <br>
        <button type="submit" name="bekräfta">Bekräfta Inköpslista</button>
    </form>
    <form method= "POST">
     <br>
        <a> Spontanköp? Lägg till här: </a>
        <input type = "text" name = "productName" required>
        <button type="submit" name="lägg_till_direkt">Lägg till varan manuellt</button>
        <br>
         </form>
    <br>
</body>
</html>