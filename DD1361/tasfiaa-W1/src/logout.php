<?php
session_start();
include 'functions.php';
$db = new SQLite3('../database/account_items.db');
if (isset($_SESSION["userID"])) {
    notActiveUser($_SESSION["userID"] , $db);
}
session_destroy(); // raderar allting som hände i den session när vi var inloggade
header("Location: index.php"); // skickar oss tillbaka till login sidan
exit();
?>