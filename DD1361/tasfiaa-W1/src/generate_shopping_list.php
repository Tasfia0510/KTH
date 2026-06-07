<?php
session_start();

include 'functions.php';

// Går till mappen där account_items.db finns 
$userID = $_SESSION['userID'];
$db = new SQLite3(__DIR__ . "/../database/account_items.db");

$allProducts = getBoughtProducts($db);
$activeProducts = getProductsFromActive($userID, $db);
$recommendedList = getRecommendedProducts($userID, $db);

//lägg till en produkt manuellt skickas vidare till modify_db där den må göra det 
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['lägg_till_manuellt'])) {
    header("Location: modify_db.php");
    exit();
}

// ta bort från inköpslistan
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['ta_bort'])) {
    $productID = $_POST['productID'];
    deleteProductFromActiveList($userID, $productID, $db);
    header("Location: generate_shopping_list.php");
    exit();
}

//lägg till direkt från rekommendationerna in i inköpslistan
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['lägg_till_direkt'])) {
    $productID = $_POST['productID'];
    addProductToList($userID, $productID, $db);
    header("Location: generate_shopping_list.php");
    exit();
}

// ta bort permanent
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['ta_bort_permanent'])) {
    $productID = $_POST['productID'];
   // $product = getProductName($productID, $db);
   // $productName = $product['productName'];

    deleteProductFromActiveList($userID, $productID, $db);
    deleteProduct($userID, $productID, $db);
    header("Location: delete.php");
    exit();
}

//bekräfta listan skickas vidare till bekräftelsesidan
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['slut_lista'])) {
    header("Location: confirm.php");
    exit();
}


?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inköpslista</title>
</head>
<body>
    <h1>Inköpslista</h1>
    <br>

    <h2>Rekommenderade varor</h2>
    <?php  if(empty($recommendedList)):?>
        <p>Inga rekommenderade varor just nu</p>
    <?php else: ?>
        <?php foreach ($recommendedList as $product): ?>
            <div>
                <?= htmlspecialchars($product['productName']) ?>
                <form method="post">
                    <input type="hidden" name="productID" value="<?= $product['productID'] ?>">
                    <button type="submit" name="lägg_till_direkt">Lägg till</button>
                </form>
            <div>
        <?php endforeach; ?>
    <?php endif; ?>
    
    <h2>Din inköpslista</h2>
    <?php  if(empty($activeProducts)):?>
        <p> Tom inköpslista :/<p>
    <?php else: ?>    
        <?php $i=0; while ($i < count($activeProducts)): ?>
            <div> 
                <?= htmlspecialchars($activeProducts[$i]['productName']) ?>
                <form method="POST">
                    <input type="hidden" name="productID" value="<?= $activeProducts[$i] ['productID'] ?>">
                    <button type="submit" name="ta_bort"> Ta bort</button>
                    <button type="submit" name="ta_bort_permanent"> Ta bort permanent</button>
                </form>
            </div>
        <?php $i++; endwhile ?>
    <?php endif; ?>
    <br>
    <p> Vet du inte vad du ska köpa? Här har du inspo från tidigare köp!</p>
    <form method="POST">
        <select name="productID">
            <?php for($i=0; $i<count($allProducts); $i++):?>
                <option value="<?= $allProducts[$i]['productID'] ?>">
                 <?= htmlspecialchars($allProducts[$i]['productName']) ?>
                </option>
            <?php endfor; ?>
        </select>     
        <button type="submit" name="lägg_till_direkt">Lägg till vara </button>
    </form>
    <br>
    <form method="POST">
        <p> Hittar du inte varan du vill lägga till? </p>
        <button type="submit" name="lägg_till_manuellt">Lägg till varan manuellt</button>
        <br>
        <p> Känner du dig klar med listan? </p>
        <button type="submit" name="slut_lista">Spara och gå vidare </button>
    </form>

    <form action="logout.php" method="post" style="position:fixed; top:10px; right:10px;">
        <button type="submit">Logga ut</button>
    </form>
</body>
</html>