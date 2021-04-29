# Using time series analysis to forecast the number of mortalities for the Florida Manatee
Data Science Practicum II Project - Forecasting Florida Manatee Mortalities


<img src="https://user-images.githubusercontent.com/54876028/116429766-2f38dc80-a814-11eb-9c36-14c368ad88f5.jpg" width="450" height="550"/>

  
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

Now, to locate the information we need from the website, we can go to the FWC website (the URL specified above), use the command `ctrl-shift-I` to inspect the webpage, navigate to the section of the page that highlights the necessary information. Usually, this is embedded in `<div>` tags.

```python
summary_files = soup.find_all('div', {'class': 'stacked single-list brown'}) #find class from inspecting website
```

To display the number of items in the `summary_files` object, we can use the command:

```python
len(summary_files)
```

There is only one item  thus we will use the command `summary_files[0]`. By printing this information, we can see that the links are embedded in  `<a>` tags. To find a link from the `summary_files[0]` variable, we can use the command:
  
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

The `FloridaManateeForecasting.R` file was used to create and analyze various forecasting models. 

### Load Data into R and Create Time Series Objects

There are various methods that can be used to load data into R. Here, we will use the `file.choose()` method, which allows us to choose the `csv` file to be uploaded into R. As mentioned above, we will be using the **yearly totals** dataset, which has been saved in the `totals.csv` file. 

```R
total_manatee <- read.csv(file = file.choose())
```
Now, our data needs to be converted to a time series object. Below, we will convert all variables in our dataset to a time series object, and will plot the data. 
```R
manatee_ts <- ts(total_manatee[2:10], start = c(1974, 1), frequency = 1) #convert to time series object for all variables
plot(manatee_ts, main = "Yearly Totals from 1974 to 2020 Plot for All Features", las = 0, cex.lab = 0.8) #plot time series data
```

<img src="https://user-images.githubusercontent.com/54876028/116271904-6e045f00-a74e-11eb-8cfe-bcfc3eff81a1.png" width="750" height="700"/>


Next, we need to isolate the yearly totals, which can be done with the commands below. 

```R
total_manatee_ts <-  ts(total_manatee$Total, start = c(1974, 1), frequency = 1) #convert to time series object for "total" column
autoplot(total_manatee_ts) + 
  geom_smooth() + 
  labs(title = "Yearly Totals from 1974 to 2020",
       y = "Totals",
       x = "Year") #plot yearly totals
```

<img src="https://user-images.githubusercontent.com/54876028/116270835-727c4800-a74d-11eb-8dc0-5e5c95add13a.png" width="650" height="600"/>

From the plot above, we can see that our data has an upward trend, but there does not appear to be any seasonality. 

### Exponential Smoothing

The simplest of exponentially smoothing methods is called *Simple Exponential Smoothing*, which is most suitable for data with no clear trend or seasonality. This method provides a way to make short-term forecasts and estimate that `alpha` parameter (level at the current time point). Values of alpha lie between 0 and 1, where a 0 means that little weight is placed on the most recent observations when making forecasts of future values. 

To do this in R, we need to set the `beta` and `gamma` parameters to false becuase beta specifies the coefficient for the trend and gamma specifies the coefficient for the seasonal smoothing. To fit a simple exponential smoothing predictive model, we will the `HoltWinters()` function. 
```R
holt_manatee <- HoltWinters(total_manatee_ts, beta = FALSE, gamma = FALSE) #fit simple exponential model 
holt_manatee #print estimated alpha parameter
holt_manatee$fitted #get forecast values for original time series (1974-2020)
plot(holt_manatee) #plot original time series against forecasts 
```
<img src="https://user-images.githubusercontent.com/54876028/116273201-8de85280-a74f-11eb-847e-677ed910d984.png" width="550" height="500"/>

To use the fitted model for forecasting, we can use the commands below. 

```R
holt_forecast <- forecast:::forecast.HoltWinters(holt_manatee, h= 10) #forecast using Holt Winters
holt_forecast #print forecast values
plot(holt_forecast) #plot forecast values
```
<img src="https://user-images.githubusercontent.com/54876028/116273128-7c9f4600-a74f-11eb-8204-3c5031d47fd1.png" width="550" height="500"/>


Finally, we need to determine if the model cannot be improved upon. We can do this by checking correlations between forecast erros for successive predictions with an ACF plot. If there are correlations, this would indicate that the simple exponential smoothing forecasts could be improved with another forecasting techniquue. To test whether there are non-zero correlations, we can use a *Ljung-Box Test*. If the p-value is greater than 0.05, this indicated that there is little evidence of non-zero correlations. Then, we check whether the forecast errors are normally distributed with mean zero (histogram of forecast residuals) and constant variance (plot forecast residuals).  
 
```R
ggAcf(holt_forecast$residuals, lag.max = 30) #ACF plot to see if there are correlations between forecast errors for successive predictions
Box.test(holt_forecast$residuals, lag = 30,type="Ljung-Box") #test whether there is significant evidence for non-zero correlations

plot.ts(holt_forecast$residuals) #plot residuals to ensure forecast error have constant variance
hist(holt_forecast$residuals, main = "Histogram of Simple Holt-Winters Resiudals", col = "blue") #plot residuals to ensure forecast error are normally distributed with mean zero
```
<img src="https://user-images.githubusercontent.com/54876028/116273338-a9535d80-a74f-11eb-8256-f27d271ae353.png" width="300" height="250"/> <img src="https://user-images.githubusercontent.com/54876028/116273402-b6704c80-a74f-11eb-8ab9-c81e109fc04f.png" width="300" height="250"/> <img src="https://user-images.githubusercontent.com/54876028/116273480-c556ff00-a74f-11eb-8806-8b5bac741198.png" width="300" height="250"/> 



Now, for time series with an increading or decreasing trend, we can use *Holt's Exponential Smoothing* to make short term forecasts. This method is similar to the simple exponential smoothing forecast method above, except both alpha and beta parameters are used. To use both alpha and beta parameters, we will set `gamma = FALSE`. 

```R
holt_manatee2 <- HoltWinters(total_manatee_ts, gamma = FALSE) # fit exponential model 
holt_manatee2 #print estimated alpha and beta parameters
holt_manatee2$fitted #get forecast values for original time series (1974-2020) 
plot(holt_manatee2) #plot original time series against forecasts
```
<img src="https://user-images.githubusercontent.com/54876028/116275766-e6205400-a751-11eb-9838-e45f83a948cd.png" width="550" height="500"/>

To use the fitted model for forecasting, we can use the commands below. 

```R
holt_forecast2 <- forecast:::forecast.HoltWinters(holt_manatee2) #forecast using Holt Winters
holt_forecast2 #print forecast values
plot(holt_forecast2) #plot forecast values
```
<img src="https://user-images.githubusercontent.com/54876028/116276060-254ea500-a752-11eb-9971-24e6f36614c2.png" width="550" height="500"/>

Similar to the steps up, we need to check correlations between forecast errors for successive predictions with an ACF plot and test whether there are non-zero correlations bu using a *Ljung-Box Test*. Then, we check whether the forecast errors are normally distributed with mean zero (histogram of forecast residuals) and constant variance (plot forecast residuals). 

```R
ggAcf(holt_forecast2$residuals, lag.max = 30) #ACF plot to see if there are correlations between forecast errors for successive predictions
Box.test(holt_forecast2$residuals, lag = 30,type="Ljung-Box") #test whether there is significant evidence for non-zero correlations
plot(holt_forecast2$residuals) #plot residuals to ensure forecast error have constant variance
hist(holt_forecast2$residuals, main = "Histogram of Simple Holt-Winters Resiudals", col = "maroon") #plot residuals to ensure forecast error are normally distributed with mean zero
```

<img src="https://user-images.githubusercontent.com/54876028/116276956-03a1ed80-a753-11eb-8625-034a4e151c9a.png" width="300" height="250"/> <img src="https://user-images.githubusercontent.com/54876028/116277008-0e5c8280-a753-11eb-848e-f831dd34d9e8.png" width="300" height="250"/> <img src="https://user-images.githubusercontent.com/54876028/116277038-161c2700-a753-11eb-8cce-fecd1b380daa.png" width="300" height="250"/> 


### ARIMA - AutoRegressive (AR) Integrated Moving Average (MA)

Another method to forecast time series is using AutoRegressive Integrated Moving Average (ARIMA) models. Before we begin building and discussing our ARIMA models, we need to test if our time series is stationary. A time series with trends and/or seasonality will affect the value of the time series at different times. A time series is considered stationary if the mean value of time series is constant over time (this implies that the trend component is nullified), the variance does not increase over time, and seasonality is minimal. To test if our data is stationary, we can use an "Augmented Dickey-Fuller Test", and if the test returns a p-value less than 0.05, the time series is considered stationary. 

```R
adf.test(total_manatee_ts, alternative = "stationary") # test if we have a stationary time series: p > 0.05, so not stationary
```
The ADF test results above indicate that our time series is not stationary, since the p-value is 0.09986, which is greater than 0.05. Another method to identify a non-stationary time series is to use an ACF (autocorrelation) plot. If the time series is stationary, the ACF plot will decrease slowly. If the time series has seasonality, the ACF plot will have a "scalloped" shape. 

```R
ggAcf(total_manatee_ts, lag = 30) #ACF plot
```
<img src="https://user-images.githubusercontent.com/54876028/116280579-d35c4e00-a756-11eb-80cd-6f06a81ae03b.png" width="550" height="500"/>

The plot above decreases slowing and doesn't drop to zero until Lag 18, which also suggests that our time series is not stationary. One way to make a non-stationary time series stationary is to compute the differences between consecutive obervations. This method is known as **differencing**. This method can help stabilize the mean of a time series by removing the changes in the level of the time series, which eliminates, or at least reduces, trend and seasonality. To perform differencing, we can use the **diff()** function. Using this data, we can use the ADF test to test if the differenced time series is stationary. The resulting p-value from the ADF test is less than 0.01 which indicates that first-order differencing the time series creates a stationary time series. 

```R
manatee_diff_ts <- diff(total_manatee_ts)
ggAcf(manatee_diff_ts, lag = 30) #ACF plot for differenced time series
autoplot(manatee_diff_ts)
```
<img src="https://user-images.githubusercontent.com/54876028/116282888-4d8dd200-a759-11eb-835e-1888834c3b39.png" width="450" height="400"/> <img src="https://user-images.githubusercontent.com/54876028/116282916-54b4e000-a759-11eb-9fd6-907ab4d7373c.png" width="450" height="400"/>

Now that we have a stationary time series, we can determine the appropriate *p*, *d*, and *q* values for an `ARIMA(p,d,q)` model.

* *p* = order of the autoregressive part - determined by viewing PACF plot
* *d* = degree of first differencing involved - determined by differencing the time series data
* *q* = order of the moving average part - determined by viewing ACF plot

There are a special cases of the ARIMA model, which are good to note because once we start combining components to form more complicated models, it is much easier to work with the backshift notation (when working with time series lags). 

* White noise: ARIMA(0,0,0)
* Random Walk (First-Order differenced time series): ARIMA(0,1,0) with no constant
* Random Walk with Drift: ARIMA(0,1,0) with a constant
* Autoregression: ARIMA(p,0,0)
* Moving Average: ARIMA(0,0,q)

It can be difficult to select appropriate values for *p*, *d*, and *q*, so we can use the `auto.arima()` function in R.

```R
fit <- auto.arima(total_manatee_ts, seasonal = FALSE)
```

The selected model for our time series is a ARIMA(2,1,2) with drift model. 

```r
fit %>% forecast(h = 10) %>% autoplot()
```
<img src="https://user-images.githubusercontent.com/54876028/116285830-87140c80-a75c-11eb-8d7c-4f72ad86ab7f.png" width="550" height="500"/>

To check the residuals of our model forecasts, we can use the code below.

```R
checkresiduals(fit)
```
<img src="https://user-images.githubusercontent.com/54876028/116290412-6e5a2580-a761-11eb-835c-daaa007f0d65.png" width="550" height="500"/>

Now, while automated models are beneficial, we can still fit the model manually by using the `Arima()` function. It should be noted that by using this function, we would be able to apply the estimated model to new data, even though this function is recommended. We can fit an ARIMA model manually by using the following general approach:

1. Plot data
2. Transform data to stabilize variance if necessary
3. Take first differences of the data until the data are stationary
4. Examine the ACF/PACF (partial autocorrelogram) plots and choose approproate ARIMA models
5. Try chosen model and use the AICc to search for a better model. We want to minimalize the Akaike’s Information Criterion (AIC)
6. Check residuals
7. Calculate forecasts once the residuals look like white noise

We have already plotted the data, which shows that our time series has an upward trend, but does not indicate changes in variance. We have also shown that the time series is non-stationary but by taking the first difference of the data, our time series is stationary. 

```r
total_manatee_ts %>% diff() %>% ggtsdisplay(main = "")
```
<img src="https://user-images.githubusercontent.com/54876028/116292267-82068b80-a763-11eb-9750-c435edaa100c.png" width="550" height="500"/>

The PACF plot above suggests an AR(2) model. Thus, an initial candidate model is an ARIMA(2,1,0) model. We will fit this model along with variations including ARIMA(3,1,0), ARIMA(3,1,1), ARIMA(2,1,1). Of these, the ARIMA(2,1,0) has a slightlt smaller AICc value.


<img src="https://user-images.githubusercontent.com/54876028/116293498-faba1780-a764-11eb-9626-760bef44f80f.png" width="550" height="500"/>

Now, we check forecast residuals.

```r
checkresiduals(fit2)
```
<img src="https://user-images.githubusercontent.com/54876028/116293602-16252280-a765-11eb-91fd-7dcfd88da503.png" width="550" height="500"/>


## Summary of Results

When determining the forecasting model for your data, there are various considerations that need to be made. A few include the amount of available data, the type of data (weekly, monthly, quarterly, annually), the forecasting horizon (will forecasting be required for one month in advance, one year, ten years, etc), and whether the data is trending or has seasonality. Our data did not have any seasonality, since we used annual data, but the data was in an upward trend. For this type of data, the two mostly used models include Exponential Smoothing and ARIMA models.  

The first modeling technique used was Exponential Smoothing. The 80% prediction interval for the 2021 forecast, and a 95% prediction interval for the 2021 forecast are in the table below. 

Model        | Alpha (α)     | Beta (β) | Gamma (γ)  | SSE  | Forecast | Lo. 80 | Hi. 80 | Lo. 95 | Hi. 95  
-----  |  -----    |  -----  | -----  | -----  | -----  |-----  |-----  |-----  | -------
Simple Exponential Smoothing | 0.3367 | NA | NA | 590679.3  | 619.8591 | 482.2740 | 757.4442 | 409.4408 | 830.2774  
Exponential Smoothing | 0.1031 | 0.4452 | NA | 490796.7  | 673.9750 | 538.6527 | 809.2973 | 467.0174 | 880.9326 

It should be noted that the Simple Exponential Smoothing has a "flat" forecast function, which means that all forecasts take the same value. In other words, the forecast model for 2021 to 2030 are all 619.8591, which can be seen in the first forecasting plot in the *Exponential Smoothing* section. As mentioned in that section, alpha and beta have values between 0 and 1, and values that are close to zero suggest that little weight is placed on the most recent observations when making forecasts of future values. In other words, the alpha (level of smoothing) value for the Simple Exponential Smoothing model suggests that the forecasts of future values rely mostly on older observations, which is similar to the alpha value for the Exponential Smoothing model. However, the beta (trend component) suggests that both recent and older observations are determinig forecast values. From the table above, the Exponential Smoothing model is a better fit due to the smaller SSE (sum of squared errors) value. 


The second modeling technique used was the ARIMA technique. The 80% prediction interval for the 2021 forecast, and a 95% prediction interval for the 2021 forecast are in the table below. 

Model  |  Log Likelihood    |  AIC | AICc | Forecast | Lo. 80 | Hi. 80 | Lo. 95 | Hi. 95 
-----  |  -----    |  -----  | -----  | -----  | -----  |-----  |-----  |-----  
ARIMA(2,1,2) with Drift  |  -272.93    |  557.87 | 560.02 | 682.7488 | 562.1076 | 803.3900 | 498.2440 | 867.2536 
ARIMA(2,1,0)  |  -281.56    |  569.13 | 569.7 | 722.2882 | 579.1161 | 865.4602 | 503.3254 | 941.2509
ARIMA(3,1,0)  |  -281.52    |  571.04 | 572.02 | 714.9832 | 570.3012 | 859.6653 | 493.7112 | 936.2553
ARIMA(3,1,1)  |  -281.27    |  572.54 | 574.04 | 692.7243 | 547.1833 | 838.2653 | 470.1385 | 915.31
ARIMA(2,1,1)  |  -281.38    |  570.76  | 571.73 | 692.0838 | 547.8892 | 836.2785 | 471.5571 | 912.6105 

Recall from above, we want our model to minimize the AICc value. Thus, the "better" ARIMA model is the ARIMA(2,1,2) with Drift model that was created using the `auto.arima()` function. This model forecasts that there will be a total of ~682 manatee mortalities, whereas the model above forecasts ~620 manatee mortalities for 2021.

### Evaluating Forecast Accuracy

One way to evaluate our forecast accuracy is to create a training and testing dataset, where the training set is used to estimate any parameters of the forecasting method and the testing data is used to evaluate the model's accuracy. Now, the training set is usually comprised of the first 75-80% of the time series data, while the testing set is the remaining 20-25%. Using the training dataset for the Exponential Smoothing and the ARIMA(2,1,2) model, we obtain the following results. 

Model  |    RMSE | MAE | MAPE | 
-----  |    -----  | -----  | -----    
Exponential Smoothing  |  174.02882  | 120.97609  | 19.67884  
ARIMA(2,1,2)  | 264.76398   | 206.96896  | 34.50

The two most commonly used measures are the Mean Absolute Error (MAE) and the Root Mean Squared Error (RMSE). Usually, the MAE is to compare forecast methods since is it easy to understand and compute. However, the RMSE is widely used. The Mean Absolute Percentage Error (MAPE) is unit-free, which makes it frequently used to compare forecast performances. Measures are based on the testing data, which serves as a more objective basis than the training period to assess predictive accuracy
 With either measure used, the results above suggest that the Exponential Smoothing method is the better method. We can also plot the results. 

<img src="https://user-images.githubusercontent.com/54876028/116443934-3c5cc800-a822-11eb-960f-a1bbb2c7cf17.png" width="550" height="500"/>

The plot above also suggests that the Exponental Smoothing model is the better model. However, other models should be explored.

## For the Future

For the future of this project, other forecasting methods can be explored such as dynamic regression models, neural network models, or bootstrapping and bagging methods. This allows us to compare more models, which then allows us to choose a more appropriate model and apply to new data. In addition, we can explore other model evaluation techniques to identify the "best" model.

Another future project idea would be to build forecasting models for the yearly totals for each cause of death (Natural, Human, etc). By analyzing these models, we can estimate which cause of death may have the most impact on the manatee population and focus on protecting the manatees. Further, forecasting models for yearly totals by county can be analyzed to identify the counties with the highest mortalities and which are predicted to have the most manatee mortalities. This combined information would be beneficial in taking steps to protect the Florida manatees.  

## Resources
1. Manatee Critical Habitat Map: https://www.fws.gov/southeast/wildlife/mammals/manatee/
2. Manatee ESA: https://www.mmc.gov/priority-topics/species-of-concern/florida-manatee/ 
3. 1974 to 2019 Yearly Mortality Summaries: https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/yearly/
4. 2020 Yearly Mortality Summary: https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/2020/
5. GET request: https://www.w3schools.com/tags/ref_httpmethods.asp
6. BeautifulSoup object: https://programminghistorian.org/en/lessons/intro-to-beautiful-soup
7. Tabula Documentation: https://tabula-py.readthedocs.io/en/latest/tabula.html
8. Use Tabula to Read PDF: https://github.com/chezou/tabula-py
9. Manatee Mortality Data (1974-2019): https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/yearly/
10. Manatee 2020 Mortality Data: https://myfwc.com/research/manatee/rescue-mortality-response/statistics/mortality/2020/
11. Convert pandas DF to CSV: https://datatofish.com/export-dataframe-to-csv/
12. Add year to column: https://stackoverflow.com/questions/20025882/add-a-string-prefix-to-each-value-in-a-string-column-using-pandas
13. Rename columns: https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.rename.html
14. re.search(): https://www.w3schools.com/python/python_regex.asp
15. Create empty dataframe and append rows: https://www.geeksforgeeks.org/create-a-pandas-dataframe-from-lists/
16. Dplyr library: https://dplyr.tidyverse.org/
17. Stationary Time Series + Stationary Time Series: http://r-statistics.co/Time-Series-Analysis-With-R.html
18. Alpha, Beta, Gamma - Exponential Smoothing: https://docs.rapidminer.com/9.3/studio/operators/modeling/time_series/forecasting/holt-winters_trainer.html
  a. https://docs.tibco.com/pub/enterprise-runtime-for-R/4.0.0/doc/html/Language_Reference/stats/HoltWinters.html 
19. Forecasting and Transformations: https://otexts.com/fpp2/
20. Forecast Accuracy: https://uc-r.github.io/ts_benchmarking
