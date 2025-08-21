# UFO-Sightings:
An exploration of the National UFO Reporting Center's dataset of 80,000 UFO sightings from 1910-2014.

1. Set-Up and Data Cleaning
Creates a new table ufo from ufo_raw.
Handles null values by removing records where both country and state are missing.
Adjusts data types: Converts columns like "date posted" to date, and splits datetime into date and time columns.
Cleans whitespace in all relevant columns.
Cleans comments: Replaces HTML character codes in the comments field with appropriate characters.
2. US-Specific Data Preparation
Identifies US sightings: For records with a missing country but a valid US state, sets country to 'us'.
Removes non-US or ambiguous records.
Creates a us_ufo table with only US sightings.
Checks for duplicates: Investigates both partial (same city/datetime) and full row duplicates.
3. Exploratory Data Analysis (EDA) on US UFO Sightings
Sightings per decade: Counts UFO sightings by decade.
Top states in the 1990s: Lists the 10 states with the most 1990s sightings.
Most common UFO shape overall.
Most common shape per year: Uses window functions to find yearly top shapes.
Most active months: Determines which month had the most sightings (July).
Duration of encounters: Compares encounters longer and shorter than 3 minutes.
4. Movies Data Preparation and EDA
Creates and cleans a movies table (from CSV), then an alien_movies table with movies related to aliens/extraterrestrials.
Cleans and adjusts data types in alien_movies.
Filters popular movies using vote count.
5. Cross-Analysis: UFO Sightings and Alien Movies
Counts UFO sightings within 30 days of hit alien movie releases.
Finds the top UFO shape sighted in the release year of each hit alien movie.
In Short:
The script cleans and prepares UFO sighting data (focused on the US), performs exploratory analysis, prepares a related alien movies dataset, and then explores relationships between UFO sightings and popular alien-themed movie releases.
