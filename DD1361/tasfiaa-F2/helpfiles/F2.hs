module F2 where
import Data.List
import Distribution.Compat.Lens (_1)
import Distribution.Compat.CharParsing (CharParsing(char))
import GHC.Generics (Datatype(moduleName))
-- UPPGIFT 2: Molekulära sekvenser

-- 2.1: Molseq som säger om en sekvens är DNA eller protein

-- data type som endast innehåller DNA och protein
data MolType = DNA | Protein deriving (Show, Eq)

-- anger sekvensnamn, sekvens och DNA/protein (med MolType)
data MolSeq = MolSeq String String MolType deriving (Show, Eq)

-- 2.2: string2seq som ska skilja på DNA och protein genom att kolla A, C, G och T för DNA 
string2seq :: String -> String -> MolSeq
string2seq name seq  
    | all (`elem` "ACGT") seq = MolSeq name seq DNA
    | otherwise = MolSeq name seq Protein

-- 2.3: Funktioner som returnerar namn, sekvens och sekvenslängd, ingen duplicering med pattern matching
seqName :: MolSeq -> String
seqName (MolSeq name _ _) = name

seqSequence :: MolSeq -> String
seqSequence (MolSeq _ seq _) = seq

seqLength :: MolSeq -> Int
seqLength (MolSeq _ seq _) = length seq

-- 2.4: Jämför två DNA respektive två protein sekvenser som ger evolutionära avstånd
seqDistance :: MolSeq -> MolSeq -> Double

seqDistance (MolSeq _ seq1 DNA) (MolSeq _ seq2 DNA)  
    | alpha > 0.74 = 3.3 
    | otherwise = -3/4 * log(1-((4/3)*alpha))
    where 
        hamming_distance = seqDifference seq1 seq2 0
        alpha = fromIntegral (hamming_distance) / fromIntegral (length seq1)

seqDistance (MolSeq _ seq1 Protein) (MolSeq _ seq2 Protein)  
    | alpha >= 0.94 = 3.7
    | otherwise = -19/20 * log(1-((20/19)*alpha))
    where 
        hamming_distance = seqDifference seq1 seq2 0
        alpha = fromIntegral (hamming_distance) / fromIntegral (length seq1)

-- "Om man försöker jämföra DNA med protein ska det signaleras ett fel med hjälp av funktionen error"
seqDistance _ _ = error "Incompatable types, cannot compare different molecule types "

-- hjälp funktion för hamming distance, räknar ut antal positioner där värdet skiljer sig åt
seqDifference :: String -> String -> Int -> Int
seqDifference [] [] ack = ack
seqDifference (x:xs) (y:ys) ack 
    | x /= y = seqDifference xs ys (ack + 1) 
    | otherwise = seqDifference xs ys ack

-- UPPGIFT 3

-- 3.1: Skapa en datatyp Profil, lagra information (matris), DNA/protein, antal sekvenser, namn 
data Profile = Profile [[(Char, Double)]] MolType Int String
    deriving (Show, Eq) 

--3.2: Funktion som returnerar en profil från givna sekvenser och sträng som namn
molseqs2profile :: String -> [MolSeq] -> Profile
molseqs2profile _ [] = error "Does not take sequence without a sequence"
molseqs2profile name seq =
    Profile matrix mol seq_length name 
    where 
        c = makeProfileMatrix seq 
        mol = seqType (head seq)
        seq_length = length seq
        number_of_seq = fromIntegral seq_length
        matrix = map (map (\(x,y) -> (x, fromIntegral y / number_of_seq))) c  

-- hjälfunktion från uppgiftsbeskrivning 
nucleotides = "ACGT"
aminoacids = sort "ARNDCEQGHILKMFPSTWYV"

-- matric C
makeProfileMatrix :: [MolSeq] -> [[(Char, Int)]]
makeProfileMatrix [] = error "Empty sequence list"
makeProfileMatrix sl = res
    where
        t = seqType (head sl)
        defaults =
            if (t == DNA) then
                zip nucleotides (replicate (length nucleotides) 0) -- Rad (i)
                -- zip skapar en lista av tupples med längden av nucleotides, alltså 4
                -- replicate duplicerar 0 i alla tupples 
                -- skapar med noll som värde 
                -- blir (A,0), (C,0), (G,0), (T,0)
            else
                zip aminoacids (replicate (length aminoacids) 0) -- Rad (ii)
                -- likannade till tidigare, bygger ihop lista av tuppler fast för proteiner
            
        strs = map seqSequence sl -- Rad (iii)
        -- seqSequence plockar endast ut sekvensen (inte namn, dna/protein)
        -- map används för att applicera seqsequence på hela listan och plocka ut alla sekvenser i en lista 

        tmp1 = map (map (\x -> ((head x), (length x))) . group . sort)
                (transpose strs) -- Rad (iv)
        -- steg 1: transponerar matrisen med bokstäver t.ex om vi har ["ACATAA", "AAGTCA"] 
        --         returneras ["AA", "CA", "AG", "TT", "AC", "AA"], map gör så för alla kolumner
        -- steg 2: sort sorterar sekvensen för att group kräver att bokstäverna är bredvid varandra i ordning t.ex ["ACA", "AAG"] till [["AAC"],["AAG"]] 
        -- steg 3: group grupperar samma bokstav t.ex [["AAA"], ["C"], ["G"]]
        -- steg 4: lamda uttryck som tar första listan och skapar en tupple med bokstaven och antal gånger den dyker upp per rad t.ex [("A", 2), ("C", 1)]
        -- steg 5: inre map räknar för hela sekvensen t.ex ["A", 2], ["C", 3] i en kolumn 

        equalFst a b = (fst a) == (fst b)
        -- jämföra tuples med första elem pga undvika dubletter när vi slår ihop listorna med unionBy
        res = map sort (map (\l -> unionBy equalFst l defaults) tmp1)
        -- skapar matrisen med värdena i rätt ordning A C G T

-- hjälpfunktion: plockar ut om sekvensen är DNA eller protein molekyl 
seqType :: MolSeq -> MolType
seqType (MolSeq _ _ mol) = mol

-- 3.3 funktion som returnerar namnet på en profil och en funktion som ger oss position och frekvens
profileName :: Profile -> String
profileName (Profile _ _ _ name) = name

-- ger oss profil typ för uppgift 4
profileType :: Profile -> MolType
profileType (Profile _ mol _ _ ) = mol

-- funktion som returnerar frekvensen för tecken på en viss position i profilen
profileFrequency :: Profile -> Int -> Char -> Double
profileFrequency (Profile matrix _ _ _) position sign = 
    helpFrequency sign (list)
    where 
        list =  matrix !! position

-- hjälpfunktion som går igenom om ett visst tecken finns i listan och returnerar frekvensen
-- genomförs rekursivt och tittar igenom hela listan tills första matchningen
helpFrequency :: Char -> [(Char, Double)] -> Double
helpFrequency _ [] = 0.0
helpFrequency sign((firstX, secondX):xs)  
    | firstX == sign = secondX 
    | otherwise = helpFrequency sign xs

-- 3.4 - avståndet mellan två profiler mäts och returnerar distansen
profileDistance :: Profile -> Profile -> Double
profileDistance (Profile m1 _ _ _) (Profile m2 _ _ _) =
    helperProfileDist m1 m2 

-- hjälpfunktion som går igenom alla kolumner, alltså positioner rekursivt
-- kallar på profileDistanceColumn som går igenom varje kolumn och summerar resultatet
helperProfileDist :: [[(Char, Double)]] -> [[(Char, Double)]] -> Double
helperProfileDist [] [] = 0.0
helperProfileDist (col1:restCol1) (col2:restCol2) = 
    profileDistanceColumn col1 col2 + helperProfileDist restCol1 restCol2

-- hjälpfunktion som räknar differansen 
profileDistanceColumn :: [(Char, Double)] -> [(Char, Double)] -> Double
profileDistanceColumn [] [] = 0.0
profileDistanceColumn ((_, freq1):rest1) ((_, freq2):rest2) = 
    abs (freq1 - freq2) + profileDistanceColumn rest1 rest2

-- UPPGIFT 4

-- 4.1 typklass för Evol (följde bara struktur i boken)
class Evol evol where
    distance :: evol -> evol -> Double 
    name :: evol -> String
    -- Fråga: Finns det någon mer funktion som man bör implementera i Evol? --> vilken typ det är (DNA/Protein)
    classification :: evol -> MolType  

    -- funktionen fungerar för alla typer som ingår i evol klassen --> automatisk definerad för sekvens och profil
    distanceMatrix :: [evol] -> [(String, String, Double)]
    -- basfall: om listan är tom finns det inga par att jämföra med
    distanceMatrix [] = []
    distanceMatrix (x:xs) =
        -- skapar tripplar genom att jämföra x med sig själv först och alla element som kommer efter
        -- t.ex om listan heter [A, B, C] får vi [(A, A), (A, B), (A, C)]
        map (\y -> (name x, name y, distance x y)) (x:xs) 
        -- anropar funktionen igen efter x, fortsätter med resten av listan och ++ slår ihop listorna till en 
        -- kan inte få dubletter t.ex (A, B) och (B, A) eftersom vi har distanceMatrix xs (och inte x:xs)  
        ++ distanceMatrix xs 

-- Molseq och Profile är instanser av Evol 
instance Evol MolSeq where
    distance = seqDistance
    name = seqName
    classification = seqType

instance Evol Profile where
    distance = profileDistance
    name = profileName
    classification = profileType
