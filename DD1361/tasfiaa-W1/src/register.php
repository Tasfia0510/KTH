<?php
// Den här sidan har till uppgift att skapa användarkonto i databasen.<br>
// Men innan kontot skapas ska en del check på indata, d.v.s. användarnamn och lösenorden göra. T.ex att användarnamnet är inte redan upptagen och indata är schyst och försöker inte manipulera databasen, databas-inhejction osv...
// När alla kontroll har genpomförts och kontot har skapats förslagsvis ska användaren bli inloggad och skickas till sidan menu.php eller du kan välja göra något annat vettigt val istället.
session_start();
require "functions.php";
$db = new SQLite3('../database/account_items.db');

// hämta användarnamn och lösenord 
$username = $_POST['username'];
$password = $_POST['password'];
$confirm = $_POST['confirm'];

// kontroll
if ($password != $confirm) {
    $_SESSION['message'] = "<p style='background-color:Tomato;'>Password does not match</p>";
    header("Location: registration.php");
    exit(); 
}

// kolla om user finns och inte är upptagen 
$checkUser = $db->prepare("SELECT * FROM users WHERE username = :username "); // prepared statement skyddar mot SQL injection
//bind värde till parameter
$checkUser-> bindValue(':username', $username, SQLITE3_TEXT); 
$result = $checkUser->execute();

if ($result->fetchArray(SQLITE3_ASSOC)) {
    $_SESSION['message'] = "<p style='background-color:Tomato;'>Username is taken</p>";
    header("Location: registration.php");
    exit();
}

// hash i rätt format 
$hashed = hash("sha3-512", $password); 

// skapar en ny rad med info i databasen, skickar in värderna, 
$insertUser = $db->prepare("INSERT INTO users (username, passwordHash, user_active) VALUES (:username, :passwordHash,0)"); // prepared statement skyddar mot SQL injection
//bind värde till parameter
$insertUser-> bindValue(':username', $username, SQLITE3_TEXT); 
$insertUser-> bindValue(':passwordHash', $hashed, SQLITE3_TEXT); 
$result = $insertUser->execute();
$userID = $db->lastInsertRowID();
activeUser($userID, $db);
$_SESSION['userID'] = $userID;
header("Location: index.php");
exit();
?> 