#tänker här kan vi skriva våra labbuppgifter 
import psycopg2
# Acquire a connection to the database by specifying the credentials.
conn = psycopg2.connect(
    host="psql-dd1368-ht25.sys.kth.se", 
    database="",
    user="användarnamn",
    password="lösenord")
print(conn)

# Create a cursor. The cursor allows you to execute database queries.
cur = conn.cursor()

# uppgift 2a
def airport_search():  
    airport = input("Enter an airport by either name and/or iata code: ")
    wildcard = f"%{airport}%"
    query= """
        SELECT Name, IATAcode, Country 
        FROM airport 
        WHERE name ILIKE %s OR IATAcode ILIKE %s;
        """
    try:
        cur.execute(query, (wildcard, wildcard))
        result = cur.fetchall()
        for Name, IATAcode, Country in result:
            print(f"{Name}: {IATAcode}: {Country}")
        print("\n")
    except: 
        print("There is no airport")

# uppgift 2b
def speakers_language():
    
    # cur.execute("""
    # SELECT DISTINCT language 
    # FROM spoken 
    # ORDER BY language;
    # """)
    # print(cur.fetchall())

    language = input("Enter a language: ")
    query = """
    WITH speakers AS(												
        SELECT s.language, c.name AS country, SUM((s.percentage / 100)* c.population)::int AS speakers
        FROM spoken s
        INNER JOIN country c ON s.country = c.code	
        WHERE s.percentage IS NOT NULL
        GROUP BY s.language, c.name
    )
    SELECT sp.country, sp.speakers		
    FROM speakers sp 
    WHERE sp.language = %s
    ORDER BY sp.country
    """

    try:
        cur.execute(query, (language,))
        result = cur.fetchall()
        print("\n")
        for country, speakers in result:
            print(f"{country}:{speakers}")
    except: 
        print("There is no such language")  

# uppgift 2c
def new_desert():
    # visa giltiga province + country
    cur.execute("""
        SELECT p.Name, c.Name
        FROM Province p
        INNER JOIN Country c ON p.Country = c.Code
        ORDER BY c.Name, p.Name;
    """)
    print("Available provinces and countries:")
    print(cur.fetchall())
    print()

    # visa alla deserts som redan finns 
    cur.execute("""
        SELECT Name
        FROM Desert
        ORDER BY Name; 
    """)
    print("Existing deserts: ")
    print(cur.fetchall())
    print()
    
    # första delen av uppgiften; se så att province namn och landets kod finns med i tabellen annars ej fortsätta
    province = input("Enter a province: ")
    country = input("Enter a country: ")

    query_province_table = """
        WITH country_code AS (
        SELECT Code
        FROM Country
        WHERE Name = %s
    )
    SELECT COUNT(*)
    FROM Province p
    INNER JOIN country_code c ON p.Country = c.Code
    WHERE p.Name = %s;
    """
    cur.execute(query_province_table, (country, province))
    province_exists = cur.fetchone()[0]

    if province_exists == 0:
        print("Province and country do not exist.")
        print("\n")
        return

    # översätt country code till country namn (så att vi kan skriva in namn på landet än koden)
    cur.execute ("SELECT Code FROM Country WHERE Name = %s;", (country,))
    country_code = cur.fetchone()[0]

    name = input("Enter a name: ")
    area = float(input("Enter an area: "))   #för att tabellen desert använder DECIMAL
    latitude = float(input("Enter latitude: "))
    longitude = float(input("Enter longitude: "))

    # ----------- P+ task 1 ---------------
    # 1. en desert kan max visa 9 provinces 
    query_desert_province = """
        SELECT COUNT(*)
        FROM geo_Desert
        WHERE Desert = %s
    """
    cur.execute(query_desert_province, (name,))
    province_count = cur.fetchone()[0]

    if province_count >= 9:
        print("ERROR! A desert can only span a maximum of 9 provinces")
        return

    # 2. Country har max 20 olika deserts 
    query_country_desert = """
        SELECT COUNT(DISTINCT Desert)
        FROM geo_Desert
        WHERE Country = %s
    """
    cur.execute(query_country_desert, (country_code,))
    desert_count = cur.fetchone()[0]

    if desert_count >= 7:
        print("ERROR! A country can only contain a maximum of 20 separate deserts")
        return 

    # 3. area är inte större än 30x än den province som finns 
    query_area_province = """
    SELECT Area
    FROM Province
    WHERE Name = %s AND Country = %s
    """
    cur.execute(query_area_province, (province, country_code))
    province_area = float(cur.fetchone()[0])

    if area > province_area * 30:
      print("ERROR! The area of a desert can be at most 30 times larger than the area of any province it occupies")
      return 

    # ----------- P+ task 1 avslutad ---------------

    # se om desert redan finns med 
    query_desert_exist = """
        SELECT COUNT(*)
        FROM Desert 
        WHERE Name = %s;
    """

    cur.execute(query_desert_exist, (name,))
    desert_exists = cur.fetchone()[0]
    is_new_desert = (desert_exists == 0)

    # om desert inte finns med ska den också läggas till i 'desert'
    if (is_new_desert):
        insert_desert = """
            INSERT INTO Desert(Name, Area, Coordinates)
            VALUES(%s, %s, ROW(%s, %s)::geocoord)
        """
        cur.execute(insert_desert, (name, area, latitude, longitude))
        print(f"New desert '{name}' added to table Desert")
    else:
        print(f"Desert '{name}' already exists in the table Desert")
        
    # oavsett om den finns med eller inte så ska den läggas till i geo_desert
    insert_geo_desert =  """
        INSERT INTO geo_Desert(Desert, Country, Province)
        VALUES(%s, %s, %s)
        ON CONFLICT (Desert, Country, Province) DO NOTHING;
    """
    cur.execute(insert_geo_desert, (name, country_code, province))

    # skriv till ngt så den läggs till i desert och titta så koordinaterna är rätt 
    print("Desert information")

    query_show_desert = """
        SELECT d.Name, d.Area, (d.Coordinates).Latitude, (d.Coordinates).Longitude, g.Province, c.Name AS Country 
        FROM Desert d
        INNER JOIN geo_Desert g ON d.Name = g.Desert
        INNER JOIN Country c ON g.Country = c.Code
        WHERE d.Name = %s AND g.Province = %s;
    """
    
    cur.execute(query_show_desert, (name, province))
    result = cur.fetchall()
    for name, area, latitude, longitude, province, country in result:
        print(f"{name}, ({province}, {country}) - Area: {area}, Coords:{latitude},{longitude})")
    conn.commit()
   

def clean_tests():
    # ta bort querys
    cur.execute("DELETE FROM geo_Desert WHERE desert = %s", ("TestDesertPorto",))
    cur.execute("DELETE FROM Desert WHERE name = %s", ("TestDesertPorto",))
    conn.commit()

if __name__ == "__main__":
   while True:

    print("MENU")
    print("1. Search for airport")
    print("2. Speakers of a language")
    print("3. New desert")
    print("4. EXIT ")

    choice = input("pick a number from the menu:")

    if choice == '1':
        airport_search()
    elif choice == '2':
        speakers_language()
    elif choice == '3':
        new_desert()
    elif choice == '4':
        print("exiting.....")
        # clean_tests()
        break
    elif choice == '5':
        a = input()
        query = """
        SELECT * FROM mountain WHERE name LIKE '%” + usersearch + “%';
        """
        cur.execute(query)
        conn.commit()
    else:
        print("this is not a choice")


# Close the connection to the database.
conn.close()
cur.close()
