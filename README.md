# UFO Sightings?
This SQL script explores the National UFO Reporting Center's [dataset](https://www.kaggle.com/code/leonardkurniadi/ufo-sightings-analysis) containing information about 80,000 UFO sightings from 1910-2014. After cleaning, filtering, and intial exploration, the data is joined with [TMDB](https://www.kaggle.com/datasets/disham993/9000-movies-dataset/data) information to analyze any potential relationships between sightings and alien movie releases.  
  
<ins>**SQL Skills Used**</ins>: CTEs, Window Functions, Inner Joins, Conditional Logic, Filtering, Aggregating, Data Cleaning/Transformation

### 1. Set-Up and Clean
- Creates a new working table ufo from ufo_raw.    
- Handles null values by removing records where both country and state are missing.  
- Adjusts data types, splits datetime into separate date and time columns for cleaner temporal analysis.
- Trims whitespace in all relevant columns.
- Replaces HTML character codes in the comments field with appropriate characters.
- Identifies hidden US sightings: For records with a missing country but a valid US state, sets country to 'us'.
- Creates a us_ufo table with only US sightings.
- Investigates both partial (same city/datetime) and full row duplicates.  

### 3. EDA on US UFO Sightings  
1. How has the number of sightings changed over time, decade by decade?  
2. What 10 states had the most sightings in the 1990s?  
3. What's the most common UFO shape overall?  
4. For each year, what was the most common shape?  
5. What month tends to have the most sightings?  
6. Do encounters tend to be longer and shorter than 3 minutes?
   
### 4. Movies Set-Up and Clean  
- Creates and cleans movies table 
- Adjusts data types, drops irrelevant columns, filters for movies with "alien" or "extraterrestrial" in the synopsis, creates new alien_movies table
- Filters out less popular titles  

### 5. Cross-Analysis: UFO Sightings and Alien Movies
1. How many sightings occured within 30 days after any given movies release?  
2. For any given movie, what was the most common shape sighted during the year of its release? 

---

**Author:** [Clara Meera](https://github.com/clarameera)  
**Repository:** https://github.com/clarameera/UFO-Sightings
