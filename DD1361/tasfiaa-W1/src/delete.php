<?php

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bekräftelse</title>
</head>
<body>
    <H1> Bekräftelse</H1>
    <p> Din produkt som du markerade kommer inte längre finnas med i framtida förslag</p>
    <form method="get" action = "generate_shopping_list">
        <br>
        <button type="submit">Tillbaka till inköpslistan</button>
    </form>
    <form method="get" action = "logout.php">
        <br>
        <button type="submit">Logga ut </button>
    </form>
</body>
</html>