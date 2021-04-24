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

Now, we can loop through our `links` list and read each `pdf` link, convert each yearly dataset to a `pandas` dataframe, and append each dataframe to a list


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




## Phase II - Exploratory Data Analysis

The `Manatee_mortality_visuals.twb` file was used to create the visualizations for the EDA portion of the project. The visualizations can be found in the `Manatee_mortality_visuals.pptx` file. Both files are located in the "Visuals" folder. 


## Phase III - Predictive Analytics

The `FloridaManateeForecasting.R` file was used to create and analyze various forecasting models.

### Holt-Winters

### ARIMA - AutoRegressive Integrated Moving Average

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
15. a
16. a
17. a
18. a
19. a
20. Forecasting: https://otexts.com/fpp2/
