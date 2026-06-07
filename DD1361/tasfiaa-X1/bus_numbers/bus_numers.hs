import Data.List (sort)

follows :: Int -> Int -> Bool
follows a b = b == a + 1

-- ska bygga och gruppera inre listor där talen är direkt i följd
-- input: [141 142 143 174 175 180], output: [[141 142 143], [174, 175], [180]]
-- bygger upp det framifrån, ber takeGroup hitta nästa grupp och anropar sig själv rekursivt på det som är kvar 
makeSublist :: [Int] -> [[Int]]
makeSublist [] = []                            
makeSublist input = 
    currGroup : makeSublist rest
    where 
        currGroup = takeGroup input             -- hämtar nästa grupp i listan
        rest = drop (length currGroup) input    -- tar bort nuvarande lista från input så att vi kan gå igenom resten

-- plockar ut en sammanhängande grupp
takeGroup :: [Int] -> [Int]
takeGroup [x] = [x]
takeGroup (x : y : rest)                        -- mönstermatchning, x = första, y = andra, rest = resten 
    | follows x y = x : takeGroup (y : rest)    -- x och y är i följd, ta med x och sen fortsätt från nästa tal som är y
    | otherwise = [x]                           -- om x och y inte är följd, stoppa och returnera det ensamt
            
fixFormat :: [Int] -> [String]
fixFormat string
    -- 3 eller fler tal
    | length string >= 3 = [show (head string) ++ "-" ++ show (last string)]
    -- allt annat (dvs 1 eller 2 tal)
    -- show omvandlar int till string, vi gör så på varje element med map, vi måste göra så för att vi har olika typer och ++ funkar endast med samma typ
    | otherwise = map show string

-- input string kommer som en full sträng, vi måste konvertera den till en lista med siffror
-- read: läser en text som integer
-- words: delar upp texten vid mellanslag (med " ")
getArraylist :: String -> [Int]
getArraylist allBuslines = map read (words allBuslines)


-- main som säger hur vi ska köra programmet (blir error utan en main)
main :: IO()
main = do
    input <- getContents                            -- läser input, som är en string
    let rows = lines input                          -- delar upp string vid radbrytningar 
    let busNumbers = getArraylist (rows !! 1)       -- tar andra elementet (index 1) som har siffrorna och gör det till en list
    let grouped = makeSublist (sort busNumbers)     -- kör vår algoritm som ger oss inre listor för efterföljande tal     
    let formattedList = map fixFormat grouped       -- rätt format för varje inre lista
    let formatted = concat formattedList            -- sätta ihop det till en som resultatet vill
    putStrLn (unwords formatted)                    -- skriver ut text som vanligt (ingen lista, krav) och går till nästa rad
