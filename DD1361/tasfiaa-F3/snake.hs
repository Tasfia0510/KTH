import UI.HSCurses.Curses
import Data.Char (ord)
import Control.Concurrent (threadDelay)

-- datatyper 

-- ormens riktningar
data Direction = North
                | South 
                | West
                | East
                deriving (Eq)

--  en orm, består av en body [(x,y)]
data Snake = Snake {
    body :: [(Int, Int)],
    control :: Direction
}

-- skapa en värld med 2 ormar, om gameover ska det printas
data World = World {
    snake1 :: Snake, 
    snake2 :: Snake, 
    boardW :: Int,
    boardH :: Int, 
    gameOver :: Bool
}

-- startvärden
initialWorld :: World 
initialWorld = World {
    snake1 = Snake [(5,20)] West,
    snake2 = Snake [(15,46)] East,
    boardW = 70,
    boardH = 30, 
    gameOver = False
}

-- buzztest, ormen ska inte kunna gå tillbaka i riktningen den kom från
oppositeDir :: Direction -> Direction 
oppositeDir d = case d of                   -- case för pattermatchning, d matchas mot varje fall
    North -> South 
    South -> North
    West -> East 
    East -> West  

-- ASCII för tangenter med små bokstäver(wasd)
-- c = tangenten, dir = nuvarande riktning
change_dir1 :: Int -> Direction -> Direction
change_dir1 c dir
    | newDir == oppositeDir dir = dir -- om nya riktningen är motsatta så igenorer vi vår input 
    | otherwise = newDir
    where 
        newDir = case c of
            119 -> North -- w
            115 -> South -- s
            97 -> West -- a
            100 -> East -- d
            _ -> dir    -- om vi inte trycker på något så behåller vi den gamla riktningen (resten av kombinationer som är kvar, alltså allt annat)

-- ASCII för piltangenter 
change_dir2 :: Int -> Direction -> Direction
change_dir2 c dir 
    | newDir == oppositeDir dir = dir 
    | otherwise = newDir
    where 
        newDir = case c of
            259 -> North
            258 -> South
            260 -> West
            261 -> East
            _ -> dir    

-- ritar grafiken
-- tar in World (speldata), Window (terminal fönstret), output IO (ritar på skärmen/terminalen)
-- använder do: allt under do körs i ordning
grafik :: World -> Window -> IO () 
grafik state screen = do
    wclear screen               -- resettar fönstret 
    drawBorder state screen     -- ritar kanterna på spelplanen 
    drawSnake state screen      -- ritar ormarna 
    wRefresh screen             -- uppdaterar värden till skärmen (terminalen visuellt)

drawBorder :: World -> Window -> IO ()
drawBorder state screen = do
    -- skapar lokala variabler w och h
    -- hämtar höjden och bredden på spelplanen från World 
    let w = boardW state 
        h = boardH state 

    -- ritning görs i (y,x)-koordinater i hscurses 
    -- map: tar en lista, applicerar något på alla i lista t.ex [1,2] blir [2,4]
    -- mapM: map fast för monader (i vårt fall IO, gör IO för varje element)
    -- mapM_: understrecket betyder att vi inte bryr oss om resultatet, endast att den ska rita

    -- rita på x axeln (y=0)
    -- mvAddCh flyttar pekaren och lägger till ett tecken på det platset, definerat under
    mapM_(\x -> do
        drawChar screen 0 x '#'         -- ritar taket, koordinater: (0,0),(0,1),...,(0,w-1) -> vänster högst upp är alltid startpunkten (0,0) 
        drawChar screen (h-1) x '#'     -- ritar golvet, koordinater: (h-1,0),(h-1,1),...,(h-1,w-1)
        ) [0 .. w-1]                    -- gör så för alla tal i bredden (x ändras)

    -- rita på y axeln (golvet)
    mapM_(\y -> do
        drawChar screen y 0 '#'         -- ritar vänstra stolpen, koordinater: (0,0),(1,0),...,(h-1,0)
        drawChar screen y (w-1) '#'     -- ritar höger stolpen, koordinater: (h-1,0),(h-1,1),...,(h-1,w-1)
        ) [0 .. h-1]                    -- gör så för alla tal i höjden (y ändras) 

-- hjälpfunktion som gör att vi kan rita tecken: flytta (wmove) och rita karaktär (waddch) samtidigt, minimerar kod duplicering
-- används för spel kanterna men också för att rita ut ormarna
-- input: fönster, y, x, tecken till fönstret
-- mvAddCh :: Int -> Int -> ChType -> IO (), den kräver siffror (ChType) men vi vill ha char 
drawChar :: Window -> Int -> Int -> Char -> IO ()
drawChar screen y x character = do
    wMove screen y x                                    -- flyttar cursern till koordinaterna 
    _ <- (waddch screen (fromIntegral (ord character))) -- nu översätts tecknet # till en siffra, alltså char till ChType med ord och skrivs med waddch, ord :: char -> int, void för vi vill endast rita inte få tillbaka något värde
    return ()                                           -- return är en funktion i Haskell som inte avslutar och inte returnerar ett värde

-- olika symboler för olika riktningar på ormen
snakeHead :: Direction -> Char 
snakeHead North = '^'
snakeHead South = 'v'
snakeHead West = '<'
snakeHead East = '>'

-- rita ormarnas huvud och kropp
drawSnake :: World -> Window -> IO ()
drawSnake state screen = do
    -- snake 1  
    let s1 = snake1 state                                       -- plockar ut ormen (döper till s1)
    let (y1,x1) = head (body s1)                                -- body s1 ger en lista av koordinater, tar första elemenet (head)
    drawChar screen y1 x1 (snakeHead (control s1))              -- ritar huvudet 
    mapM_(\(y,x) -> drawChar screen y x '#') (tail (body s1))   -- sen ritar den kroppen, map för att vi måste rita ut hela kroppen hela tiden

    -- snake 2
    let s2 = snake2 state 
    let (y2,x2) = head (body s2)
    drawChar screen y2 x2 (snakeHead (control s2))
    mapM_(\(y,x)-> drawChar screen y x '#') (tail (body s2))

-- uppdaterar positionen för en orm
moveSnake :: Snake -> Snake 
moveSnake s = s {body = newHead : body s}
    where 
        (y,x) = head (body s) 
        (dy,dx) = case control s of 
            North -> (-1,0)
            South -> (1,0)
            West -> (0,-1)
            East -> (0,1)
        newHead = (y+dy, x+dx)

-- Kollision om en orm nuddar med spelplanets gränser så ska spelet vara över, dvs gameOver = true
collideBorder :: World -> Snake -> Bool
collideBorder w s 
        | y <= 0 = True 
        | y >= boardH w - 1 = True 
        | x <= 0 = True
        | x >= boardW w - 1 = True
        | otherwise = False
        where (y,x) = head (body s) 

-- kollision om ormen nuddar sig självt 
-- `elem` kollar om något finns i listan
collideSelf :: Snake -> Bool
collideSelf s 
    | head(body s ) `elem` tail (body s) = True
    | otherwise = False

-- Kollision om ormen nuddar en annan orm 
collideSnakes :: Snake -> Snake -> Bool
collideSnakes s1 s2 
    | head (body s1) `elem` (body s2) = True
    | head (body s2) `elem` (body s1) = True
    | otherwise = False 

-- Samlade kollisioner
collision :: World -> Bool
collision w =
    collideBorder w (snake1 w ) ||
    collideBorder w (snake2 w) ||
    collideSelf (snake1 w) || 
    collideSelf (snake2 w ) || 
    collideSnakes (snake1 w ) (snake2 w)

-- spel loopen, använder guards, här uppdateras spelet 
gameLoop :: World -> Window -> IO () 
gameLoop state screen 
    | gameOver state = do -- om spelet är slut ska allt under göras
        mvWAddStr screen (boardH state + 1) 0 ("Game Over!") -- mvWAddStr låter oss skriva en string på skärmen
        wRefresh screen -- uppdatera display
        getCh -- måste vänta för input, annars händer inget, är blockerande
        return()
         
    | otherwise = do 
        grafik state screen -- ritar hela spelet
        threadDelay 100000 -- pausar i 0,1 sek

        ch <- getch -- getch väntar på tangenter, lägger resultatet i ch
        let c = fromIntegral ch -- gör om ch till integer

        let s1 = snake1 state 
        let s2 = snake2 state

        -- om ingen tanget har tryckts (-1) så fortsätter den gå som vanligt, behåller riktningen
        -- annars uppdatera orm i ny riktning
        let s1_new 
                | c == (-1) = s1
                | otherwise = s1 {control = change_dir1 c (control s1)}

        let s2_new 
                | c == (-1) = s2
                | otherwise = s2 {control = change_dir2 c (control s2)}

        -- flytta ormen, uppdaterar position baserat på riktning
        let moved1 = moveSnake s1_new
        let moved2 = moveSnake s2_new

        -- skapar ett nytt spelstånd
        let newState = state {
            snake1 = moved1,
            snake2 = moved2,
            gameOver = collision newState
            }

        gameLoop newState screen -- rekursivt anrop med nya värden

main :: IO ()
main = do
    initCurses                  -- startar biblioteket
    s <- initScr                -- skapar windpw, skapar fönstret + refreshar  
    cBreak True                 -- användaren ska inte behöva trycka på enter för att starta spelet, spelet startas direkt 
    keypad s True               -- tangenter för spelarna
    timeout 30                  -- hur länge vi väntar på input i millisekunder (därför kan ormarna röra på sig utan att man trycker), annars blir spelet blockande
    gameLoop initialWorld s     -- startar spel loopen med all grafik
    endWin                      -- stänger cursern och återställer terminalen