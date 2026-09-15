import pandas as pd
from sqlalchemy import create_engine
from getpass import getpass
from pathlib import Path

# Read the cleaned CSV file
csv_file = Path(__file__).parent.parent / "Excel" / "superstore_cleaned.csv"

df = pd.read_csv(csv_file)

print("Total rows in CSV:", len(df))

# Ask for MySQL password securely
password = getpass("Enter MySQL Password: ")

# Connect to MySQL
engine = create_engine(
    f"mysql+pymysql://root:{password}@localhost:3306/superstore_project"
)

# Import data into MySQL
df.to_sql(
    "superstore_cleaned",
    con=engine,
    if_exists="fail",
    index=False
)

print("Data imported successfully")