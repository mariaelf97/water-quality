from matplotlib import pyplot as plt
import requests
import pandas as pd
api_endpoint = 'https://data.ca.gov/api/3/action/datastore_search?resource_id=3532a18a-de6d-4d4c-abcf-285f1a972ea9&limit=50000'

response = requests.get(api_endpoint)

if response.status_code == 200:
    df_stations = pd.DataFrame(response.json()['result']['records'])
    print(df_stations)  
    
else:
    print(f"Failed to retrieve data: {response.status_code}")

station_counts = df_stations.groupby(['county_name', 'station_type']).size().unstack(fill_value=0)
station_counts.plot(kind='bar', stacked=True, figsize=(12, 6))
plt.xlabel('County')
plt.ylabel('Number of Stations')
plt.title('Distribution of Groundwater and Surfacewater Stations by County')
plt.legend(title='Station Type')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.show()
plt.savefig('Distribution_of_Groundwater_and_Surfacewater_Stations_by_County.png')


