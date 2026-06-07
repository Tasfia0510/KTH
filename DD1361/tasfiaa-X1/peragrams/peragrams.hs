import Data.List (nub, sort)

-- motsvarar count/3 
-- prolog räknar rekursivt med via mönster matchning (definerar regler), haskell använder filter och length (definerar funktioner)
-- tar en bokstav, tar strängen, returnerar hur många gånger den bokstaven finns 
count :: Char -> String -> Int
count c chars = 
    -- behåller endast matchande bokstaven med filter, tar sen längden av den
    length (filter (== c) chars)

-- motsvarar count_odd/3 
-- returnerar antal bokstäver som har en udda frekvens
count_odd :: [Char] -> String -> Int 
count_odd [] _ = 0
count_odd (x:xs) chars =
    -- räknar frekvensen av första bokstaven (x), rekurivt går igenom resten
    add_odd (count x chars) (count_odd xs chars)

-- motsvarar add_odd/3 
add_odd :: Int -> Int -> Int
add_odd freq rest 
    | odd freq = rest + 1
    | otherwise = rest 

-- motsvarar check/2 
-- en string i haskell är redan en lista av chars (separata karaktärer) så vi kan skippa det
check :: String -> Int
check word = 
    max 0 (oddCount - 1)
    where
        -- motsvarar sort/2
        uniqueChars = nub (sort word)
        oddCount = count_odd uniqueChars word

main :: IO ()
main = do
    word <- getLine         -- läser input 
    print (check word)      -- skriver ut resultat
