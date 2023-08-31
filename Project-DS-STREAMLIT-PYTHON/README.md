# Project Showcase - HR Analytics - Build a Data Science Web App with Streamlit and Python

## Project Overview
Welcome to the Motor Vehicle Collisions Analysis Dashboard, a Streamlit-powered web application designed to help you explore and analyze motor vehicle collisions in New York City. With interactive maps, charts, and data visualizations, this dashboard provides insights into various aspects of vehicle collisions within NYC.

| ![img1.PNG](img%2Fimg1.PNG) | ![img2.PNG](img%2Fimg2.PNG) |
| --- | --- |
| ![img3.PNG](img%2Fimg3.PNG) | ![img4.PNG](img%2Fimg4.PNG) |


## Features
### 1) Data Loading and Preprocessing

* The application loads motor vehicle collision data from a CSV file using Pandas.
* It parses the date and time columns for analysis.
* Data with missing latitude and longitude values is filtered out.

### 2) Interactive Map
* Visualize collision incidents on an interactive map of NYC.
* Adjust the filter to view incidents with a minimum number of injured persons.

### 3) Time of Day Analysis
* Explore collisions occurring during a specific hour of the day.
* Examine collisions between selected hours using a 3D interactive map.

### 4) Hourly Breakdown
* View the breakdown of collisions by minute within a selected hour.
* Histogram charts show the distribution of collisions throughout the hour.

### 5) Top Dangerous Streets
* Analyze the top 5 streets with the highest number of injuries based on the type of affected people (Pedestrians, Cyclists, Motorists).

### 6) Raw Data Viewing
* Toggle to view the raw data used for analysis.


## Libraries Used
- [Streamlit](https://streamlit.io/)
- [Pandas](https://pandas.pydata.org/)
- [Numpy](https://numpy.org/)
- [Pydeck](https://pydeck.gl/)
- [Plottly Express](https://plotly.com/python/plotly-express/)

## Data
- In this project we used data from [Motor_Vechiles_Dataset](data\Motor_Vehicle_Collisions_-_Crashes.csv)

## How to Use
* Clone the repository: git clone 
* Install the required dependencies: pip install streamlit pandas numpy pydeck plotly
* Run the Streamlit app: streamlit run app.py