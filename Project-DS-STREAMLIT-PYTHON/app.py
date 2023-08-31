import streamlit as st
import pandas as pd
import numpy as np
import pydeck as pdk
import plotly.express as px

DATA_URL = (
    "data\sample_file.csv"
)



st.title("Motor Vehicle Collisions in New York City")
st.markdown("This application is a streamlit dashboard that can be used to analyze motor vehicle collisions in NYC 🗽💥🚗")


# Load the Motor Vehicle Collisions Data
@st.cache_data()
def load_data(nrows):
    data = pd.read_csv(DATA_URL, nrows=nrows, parse_dates=[['CRASH_DATE', 'CRASH_TIME']])
    data.dropna(subset=['LATITUDE', 'LONGITUDE'], inplace=True)
    lowercase = lambda x: str(x).lower()
    data.rename(lowercase, axis="columns", inplace=True)
    data.rename(columns={"crash_date_crash_time": "date/time"}, inplace=True)
    return data

data = load_data(100000) # goes up to 100000

# Visualize Data on a Map
st.header("Where are the most people injured in NYC?")
injured_persons = st.slider("Number of persons injured in vehicle collisions", 0, 19)
filtered_data = data.query("injured_persons >= @injured_persons")[["latitude", "longitude"]].dropna(how="any")
st.map(filtered_data)

# Filtering Data and Interactive Tables
st.header("How many collisions occur during a given time of day?")
hour = st.slider("Hour to look at", 0, 23)
original_data = data
data = data[data['date/time'].dt.hour == hour]

# Plot Filtered Data on a 3D Interactive Map
st.markdown("Vehicle collisions between %i:00 and %i:00" % (hour, (hour + 1) % 24))
midpoint = (np.average(data["latitude"]), np.average(data["longitude"]))

st.write(pdk.Deck(
    map_style="mapbox://styles/mapbox/light-v9",
    initial_view_state={
        "latitude": midpoint[0],
        "longitude": midpoint[1],
        "zoom": 11,
        "pitch": 50,
    },
    layers=[
        pdk.Layer(
        "HexagonLayer",
        data=data[['date/time', 'latitude', 'longitude']],
        get_position=["longitude", "latitude"],
        auto_highlight=True,
        radius=100,
        extruded=True,
        pickable=True,
        elevation_scale=4,
        elevation_range=[0, 1000],
        ),
    ],
))

# Charts and Histograms
st.subheader("Breakdown by minute between %i:00 and %i:00" % (hour, (hour + 1) % 24))
filtered = data[
    (data['date/time'].dt.hour >= hour) & (data['date/time'].dt.hour < (hour + 1))
]
hist = np.histogram(filtered['date/time'].dt.minute, bins=60, range=(1, 60))[0]
chart_data = pd.DataFrame({"minute": range(60), "crashes": hist})
fig = px.bar(chart_data, x='minute', y='crashes', hover_data=['minute', 'crashes'], height=400)
st.write(fig)

# Select Data Dropdowns
st.header("Top 5 dangerous streets by affected type of people")
select = st.selectbox('Affected type of people', ['Pedestrians','Cyclists',' Motorists'])


if select == 'Pedestrians':
    st.write(
        original_data.query("injured_pedestrians >= 1")[['on_street_name','injured_pedestrians']]
        .sort_values(by=['injured_pedestrians'],ascending=False)
        .dropna(how='any')[:5]
        )
elif select == 'Cyclists':
    st.write(
        original_data.query("injured_cyclists >= 1")[['on_street_name','injured_cyclists']]
        .sort_values(by=['injured_cyclists'],ascending=False)
        .dropna(how='any')[:5]
        )
else:
    st.write(
        original_data.query("injured_motorists >= 1")[['on_street_name','injured_motorists']]
        .sort_values(by=['injured_motorists'],ascending=False)
        .dropna(how='any')[:5]
        )


if st.checkbox("Show Raw Data", False):
    st.subheader('Raw Date')
    st.write(data)