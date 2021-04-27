## Libraries ---------------------------------------------------------

library(dplyr)
library(tseries)
library(ggplot2)
library(forecast) 

## Load CSV Files ---------------------------------------------------------

total_manatee <- read.csv(file = file.choose()) #load totals dataset
total_manatee %>% head(5)
View(total_manatee)

## Time Series and Plots---------------------------------------------------------

manatee_ts <- ts(total_manatee[2:10], start = c(1974, 1), frequency = 1) #convert to time series object for all variables
manatee_ts %>% head(12) #view first 12 observations


plot(manatee_ts, main = "Yearly Totals from 1974 to 2020 Plot for All Features", las = 0, cex.lab = 0.8) #plot time series data

total_manatee_ts <-  ts(total_manatee$Total, start = c(1974, 1), frequency = 1) #convert to time series object for "total" column

autoplot(total_manatee_ts) + 
  geom_smooth() + 
  labs(title = "Yearly Totals from 1974 to 2020",
       y = "Totals",
       x = "Year") #plot yearly totals

# gglagplot(total_manatee_ts, lags = 12) #lag plot


## Forecasts using Holt's Simple Exponential Smoothing ---------------------------------------------------------

holt_manatee <- HoltWinters(total_manatee_ts, beta = FALSE, gamma = FALSE) #fit simple exponential model 
holt_manatee #print estimated alpha parameter
holt_manatee$fitted #get forecast values for original time series (1974-2020)
plot(holt_manatee) #plot original time series against forecasts 

holt_manatee$SSE 
  #As a measure of the accuracy of the forecasts,
  #we can calculate the sum of squared errors for the in-sample
  #forecast errors, that is, the forecast errors for the time period covered by our original time series

holt_forecast <- forecast:::forecast.HoltWinters(holt_manatee, h= 10) #forecast using Holt Winters
holt_forecast #print forecast values
plot(holt_forecast) #plot forecast values



ggAcf(holt_forecast$residuals, lag.max = 30) #ACF plot to see if there are correlations between forecast errors for successive predictions
Box.test(holt_forecast$residuals, lag = 30,type="Ljung-Box") #test whether there is significant evidence for non-zero correlations

plot.ts(holt_forecast$residuals) #plot residuals to ensure forecast error have constant variance
hist(holt_forecast$residuals, main = "Histogram of Simple Holt-Winters Resiudals", col = "blue") #plot residuals to ensure forecast error are normally distributed with mean zero


## Forecasts using Holt's Simple Exponential Smoothing with Trend ------------------------------------------------------------------------------------------------------------------

holt_manatee2 <- HoltWinters(total_manatee_ts, gamma = FALSE) # fit exponential model 
holt_manatee2 #print estimated alpha and beta parameters
holt_manatee2$fitted #get forecast values for original time series (1974-2020) 
plot(holt_manatee2) #plot original time series against forecasts

holt_manatee2$SSE 
  #As a measure of the accuracy of the forecasts,
  #we can calculate the sum of squared errors for the in-sample
  #forecast errors, that is, the forecast errors for the time period covered by our original time series


holt_forecast2 <- forecast:::forecast.HoltWinters(holt_manatee2) #forecast using Holt Winters
holt_forecast2 #print forecast values

plot(holt_forecast2) #plot forecast values


ggAcf(holt_forecast2$residuals, lag.max = 30) #ACF plot to see if there are correlations between forecast errors for successive predictions
Box.test(holt_forecast2$residuals, lag = 30,type="Ljung-Box") #test whether there is significant evidence for non-zero correlations


plot(holt_forecast2$residuals) #plot residuals to ensure forecast error have constant variance
hist(holt_forecast2$residuals, main = "Histogram of Simple Holt-Winters Resiudals", col = "maroon") #plot residuals to ensure forecast error are normally distributed with mean zero



## Differencing A Time Series ---------------------------------------------------------

adf.test(total_manatee_ts, alternative = "stationary") # test if we have a stationary time series: p > 0.05, so not stationary
ggAcf(total_manatee_ts, lag = 30) #ACF plot

manatee_diff_ts <- diff(total_manatee_ts)
adf.test(manatee_diff_ts, alternative = "stationary") # test if we have a stationary time series: p > 0.05, so not stationary
ggAcf(manatee_diff_ts, lag = 30) #ACF plot for differenced time series
autoplot(manatee_diff_ts)



## ARIMA ---------------------------------------------------------

#auto ARIMA
fit <- auto.arima(total_manatee_ts, seasonal = FALSE)
fit
fit %>% forecast(h = 10)
fit %>% forecast(h = 10) %>% autoplot() #plot forecasts, 10 years in the future
checkresiduals(fit) #check residuals

total_manatee_ts %>% diff() %>% ggtsdisplay(main = "") #used to choose appropriate values

#choose model with smallest AICc value
fit2 <- Arima(total_manatee_ts, seasonal = FALSE, order = c(2,1,0))
fit2
fit3 <- Arima(total_manatee_ts, seasonal = FALSE, order = c(3,1,0))
fit3
fit4 <- Arima(total_manatee_ts, seasonal = FALSE, order = c(3,1,1))
fit4
fit5 <- Arima(total_manatee_ts, seasonal = FALSE, order = c(2,1,1))
fit5


fit2 %>% forecast(h = 10)
fit2 %>% forecast(h = 10) %>% autoplot()
checkresiduals(fit2)



## Resources ---------------------------------------------------------

#1. Stationary Time Series + Stationary Time Series: http://r-statistics.co/Time-Series-Analysis-With-R.html
#3. ggAcf: https://Otexts.com/fpp2/
#4. Accuracy: https://a-little-book-of-r-for-time-series.readthedocs.io/en/latest/src/timeseries.html
#5. dplyr: https://dplyr.tidyverse.org/
#6. forecast: https://cran.r-project.org/web/packages/forecast/forecast.pdf

