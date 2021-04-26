# Using time series analysis to forecast the number of mortalities for the Florida Manatee
Data Science Practicum II Project - Forecasting Florida Manatee Mortalities


## Summary

One major issue in the state of Florida is trying to increase the manatee population. Until recently, the Florida manatee was listed as endangered under the Endangered Species Act (ESA). Identifying areas where manatee deaths occur the most and identifying the major cause of death for this species can be crucial information when deciding the best course of action in protecting and growing the manatee population. By using time series data, which refers to observations that are collected sequentially in time, we can build a model to predict future values of the time series. Forecasting allows us to take the models fit on the historical data and use them to predict future observations.

Using yearly manatee mortality summaries created by the wiildlife experts with the Florida Fish and Wildlife Conservation Commission (FWC), we can create models that allow us to forecast the total number of manatee deaths per year. This project will focus on creating a model that forecasts the **yearly total** number of manatee deaths.

### Data

Wildlife experts with the FWC perform consistent, high quality postmortem examinations of manatee carcasses that they discover or that are reported to them. Results from the examinations are summarized and available to be searched by county, year, and probable cause of death. The data used for this project will be the yearly summaries for 1974 to 2020.

Each yearly summary contains information for Florida counties that had manatee deaths and one row containing information for the total number of deaths by cause. There are approximately ~35 observations and 10 features in each yearly summary and 47 yearly summaries will be used. It should be noted that the older data (1974, 1975, etc.) may contain less data. This data will be collected using web-scraping techniques and then the `Tabula` module will extract the tables from the yearly summary PDF's and store them into a `pandas` DataFrame. Each set of data will then be saved as a `csv` file.

### Methodology

Anaconda version 4.8.3, Tableau Desktop version 2019.3, and R version 4.0.3 was used to complete this project. Anaconda allowed us to utilize Jupyter Notebooks, which used Python version 3.7.4. Jupyter was used to scrape the FWC website and convert the data to `csv` files. Tableau was used for the exploratory data analysis (EDA) portion of the project. Finally, R was used to analyze the time series data and build the forecasting models. 

#### Tools and Libraries

* Python
   * `import requests as req`: Used for webscraping; get URL
   * `from bs4 import BeautifulSoup as bs`: Convert to BeautifulSoup object
   * `import tabula`: Import tabula to read tables from PDF's
   * `import pandas as pd`: Convert to pandas DF
   * `import os.path`: Check if file exists for a desired folder/path
   * `import re`: Search if string exists in dataframe row
* Tableau
* R
  * `library(dplyr)`: Used for data manipulation
  * `library(tseries)`: Converts data to a time series object
  * `library(ggplot2)`: Create graphics of time series data and forecast models
  * `library(forecast)`: Display and analyze time series forecasts 


## Phase I - Data Collection

The `ReadManateePDFs.ipynb` file was used for the data collection portion of the assignment.

### Step 1: Webscraping using `BeautifulSoup`

To scrape the data from the FWC website, we first need to send a GET request to the specified url, which is used to request data from a specified resource.

```python
res = req.get('https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/yearly/') #GET request for url
```
Using the requested data above, we then convert the data to a BeautifulSoup object, which allows us to easily locate and select content within the HTML structure.

```python
soup = bs(res.content, 'lxml') #Convert to Beautiful Soup object
```

Now, to locate the information we need from the website, we can go to the FWC website (the URL specified above), use the command `ctrl-shift-I` to inspect the webpage, navigate to the section of the page that highlights the necessary information. Usually, this is embedded in "<div>" tags.

```python
summary_files = soup.find_all('div', {'class': 'stacked single-list brown'}) #find class from inspecting website
```

To display the number of items in the `summary_files` object, we can use the command:

```python
len(summary_files)
```

There is only one item, thus we will use the command `summary_files[0]`. By printing this information, we can see that the links are embedded in  "<a>" tags. To find a link from the `summary_files[0]` variable, we can use the command:
  
```python
summary_files[0].find('a') #find a link from webpage list of links
```

The output from this will look like: `<a href="/media/11661/1974yearsummary.pdf" target="_blank">1974</a>`. To obtain the link, we can use the command:

```python
summary_files[0].find('a').get('href') #get href
```

The ouput will look like `'/media/11661/1974yearsummary.pdf'`. Now, to loop through the `summary_files[0]` variable, get all the "href" links, and add the links to a list, we can use the code below.


```python
#loop through summary_files and get all href's and add full link to list

links = []
base_url = "https://myfwc.com/" #base url of all links

for x in summary_files[0].find_all("a"):
    href = x.get("href")
    full_link = base_url + href 
    links.append(full_link)

links[0] #print first link 
```

By printing the first link, we can verify that the link format is correct and that the data was appended to the list properly. The output from printing the first link is `'https://myfwc.com//media/11661/1974yearsummary.pdf'`, which is the 1974 manatee summary data. 

### Step 2: Extract Data using `tabula`

The `tabula` module allows us to extract data tables from a `pdf` file. To do this, we will read each of our `pdf` links obtained above. First, we will need to add the link for the year 2020 to our list, which we can do using the command below. 

```python
links.append("https://myfwc.com/media/22565/yeartodate.pdf") # add link for 2020 yearly data to links list 
```

Now, we can loop through our `links` list and read each `pdf` link, convert each yearly dataset to a `pandas` dataframe, and append each dataframe to a list.


```python
#convert data in links collected above to pandas_df
data = []

for link in links:
    df = tabula.read_pdf(link, pages=1) #read file using tabula
    panda_df = pd.DataFrame(df[0]) #convert to pandas df
    test_df = panda_df.dropna(axis='rows').reset_index(drop=True) #drop rows with NA's and reset index count
    data.append(test_df) #append to data list
```

The `data` list should contain 47 dataframes.


### Step 3: Convert to `csv` Files

Before we convert our dataframes to `csv` files, we need to clean our data and create a dataframe that is made of all 47 yearly data summaries. First, we will add the corresponding year to each "County" column in the dataframes.

```python
# Add corresponding year to each "County" 
year = 1974

for d in data:
    d['County'] = d['County'].apply(lambda x: "{}{}".format(x , year))
    year = year + 1
```

Now, to create our **full dataframe**, we will concatenate our dataframes using the `pandas` function `concat()`. We will also need to rename the columns. It should be noted that since some of the columns were renamed in the 1980's so we will have columns that will need to be merged. These columns are denoted as "A1", "A2", "B1", and "B2".

```python
full_data = pd.concat(data) #Concatenate all collected dataframes
full_data = full_data.rename(columns={"County": "County/Year","Watercraft":"Watercraft","Flood":"A1",
                          "Other":"Other/Human","Perinatal":"Perinatal","Cold":"Cold Stress","Natural":"Natural",
                          "Undetermined":"B1","Unrecovered":"B2","Total":"Total","Flood Gate/":"A2",
                          "Not":"Not Necropsied"}) #rename columns
```

We will also need to convert all the columns to the same datatype. Thus, we will convert them to float numbers. 

```python
full_data['A1'] = full_data['A1'].astype(float)
full_data['A2'] = full_data['A2'].astype(float)
full_data['Not Necropsied'] = full_data['Not Necropsied'].astype(float)
full_data['Other/Human'] = full_data['Other/Human'].astype(float)
full_data['Cold Stress'] = full_data['Cold Stress'].astype(float)
```

Now, we can combine the "A1" column with the "A2" column, and combine the "B1" column with the "B2" column. After merging these columns, we can drop them.

```python
# combine A1 with A2 and B1 with B2
full_data["Flood Gate/Canal Lock"] = full_data["A1"] + full_data["A2"]
full_data["Unrecovered/Undetermined"] = full_data["B1"] + full_data["B2"]

#drop combined columns
full_data = full_data.drop(["A1", "A2", "B1", "B2"], axis="columns")
```

To store this file as a `csv` file, we can specify the path where we want to store the file (denoted as `folder` below).

```python
full_data.to_csv(folder+'full_data.csv', index=False, header=True)
```
Finally, each collected yearly summary was converted to a `csv` file, and a `csv` file that contains the yearly totals from each summary was also created (`totals.csv`). This file will be used for the predictive modeling portion of this project.


## Phase II - Exploratory Data Analysis

The `Manatee_mortality_visuals.twb` file was used to create the visualizations for the EDA portion of the project. The visualizations can be found in the `Manatee_mortality_visuals.pptx` file. Both files are located in the "Visuals" folder. 


## Phase III - Predictive Analytics

The `FloridaManateeForecasting.R` file was used to create and analyze various forecasting models. All plots created in this sections can be found in the "R Graphics" folder.


### Load Data into R and Create Time Series Objects

There are various methods that can be used to load data into R. Here, we will use the `file.choose()` method, which allows us to choose the `csv` file to be uploaded into R. As mentioned above, we will be using the **yearly totals** dataset, which has been saved in the `totals.csv` file. 

```R
total_manatee <- read.csv(file = file.choose())
```
Now, our data needs to be converted to a time series object. Below, we will convert all variables in our dataset to a time series object, and will plot the data. Plot Name: `Yearly_total_ts_plot.png`

```R
manatee_ts <- ts(total_manatee[2:10], start = c(1974, 1), frequency = 1) #convert to time series object for all variables
plot(manatee_ts, main = "Yearly Totals from 1974 to 2020 Plot for All Features", las = 0, cex.lab = 0.8) #plot time series data
```
Next, we need to isolate the yearly totals, which can be done with the commands below. Plot Name: `yearly_totals_trend`


```R
total_manatee_ts <-  ts(total_manatee$Total, start = c(1974, 1), frequency = 1) #convert to time series object for "total" column
autoplot(total_manatee_ts) + 
  geom_smooth() + 
  labs(title = "Yearly Totals from 1974 to 2020",
       y = "Totals",
       x = "Year") #plot yearly totals
```

From the plot above, we can see that our data has an upward trend, but there does not appear to be any seasonality. 

### Exponential Smoothing

The simplest of exponentially smoothing methods is called *Simple Exponential Smoothing*, which is most suitable for data with no clear trend or seasonality. 

### ARIMA - AutoRegressive Integrated Moving Average

Before we begin building our ARIMA models, we need to test if our time series is stationary. A time series is considered stationary if the mean value of time series is constant over time (this implies that the trend component is nullified), the variance does not increase over time, and seasonality is minimal. To test if our data is stationary, we can use an "Augmented Dickey-Fuller Test", and if the test returns a p-value less than 0.05, the time series is considered stationary. 

```R
adf.test(total_manatee_ts, alternative = "stationary") # test if we have a stationary time series: p > 0.05, so not stationary
```
Another method to identify a non-stationary time series is to use an ACF (autocorrelation) plot. If the time series is stationary, the ACF plot will decrease slowly. If the time series has seasonality, the ACF plot will have a "scalloped" shape. Plot Name: `nonstationary_timeseries_ACF.png`

```R
ggAcf(total_manatee_ts, lag = 30) #ACF plot
```
The plot above decreases slowing and doesn't drop to zero until Lag 18  make 



* *p* = order of the autoregressive part
* *d* = degree of first differencing involved
* *q* = order of the moving average part.

## For the Future


## Resources
1. Manatee ESA: https://www.mmc.gov/priority-topics/species-of-concern/florida-manatee/ 
2. 1974 to 2019 Yearly Mortality Summaries: https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/yearly/
3. 2020 Yearly Mortality Summary: https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/2020/
4. GET request: https://www.w3schools.com/tags/ref_httpmethods.asp
5. BeautifulSoup object: https://programminghistorian.org/en/lessons/intro-to-beautiful-soup
6. Tabula Documentation: https://tabula-py.readthedocs.io/en/latest/tabula.html
7. Use Tabula to Read PDF: https://github.com/chezou/tabula-py
8. Manatee Mortality Data (1974-2019): https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/yearly/
9. Manatee 2020 Mortality Data: https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/2020/
10. Convert pandas DF to CSV: https://datatofish.com/export-dataframe-to-csv/
11. Add year to column: https://stackoverflow.com/questions/20025882/add-a-string-prefix-to-each-value-in-a-string-column-using-pandas
12. Rename columns: https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.rename.html
13. re.search(): https://www.w3schools.com/python/python_regex.asp
14. Create empty dataframe and append rows: https://www.geeksforgeeks.org/create-a-pandas-dataframe-from-lists/
15. Stationary Time Series + Stationary Time Series: http://r-statistics.co/Time-Series-Analysis-With-R.html
16. Forecasting and Transformations: https://otexts.com/fpp2/
