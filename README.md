# fnugg

Why check the weather in the terminal? Because reasons.

Why fnugg? Snøfnugg is Norwegian for snowflake.

~~'fnugg notification' will show current temperature notification every 30 min.~~
'fnugg small' Default view, showing only current and then each day.
'fnugg notification' The old standard view, with three different forecast par page.

Powered by [Dark Sky](http://darksky.net) & [Mapbox](https://www.mapbox.com).
(*You need API keys from both services to make fnugg functional.*)

## How to install

Install [doghum](https://github.com/DokterW/doghum)

`doghum install fupr`

### Roadmap

* Add ability to save favourite locations.
* Maybe re-enable notifications again.
* Add legacy function.
* Tweak code before v1.0 is released.

### Changelog

#### 2018-04-29
* Bug fix

#### 2018-04-28
* More minor tweaks

#### 2018-04-25
* Minor tweaks

#### 2018-03-27
* Added GeoIP feature.

#### 2018-01-05
* Added an extra error message. By random it will either say Butterfingers! or Sausage Fingers! (requested by cleo)
* Fixed when changing Ö/Ø to OE instead of O, and Ä/Æ to AE instead of A. This was because some city names do not accept only A, but want AE.

#### 2017-10-24
* Show time and date when weather data was fetched.
* Page indicator.
* Refresh fix (if it refreshed every 10 min it only reloaded the old data).

#### 2017-10-23
* Disabled notifications.
* Added two different views, large (the one that was standard) and small. Small is default now, to use large, type *fnugg large*.
* Not thoroughly tested.

#### 2017-09-16
* 6-day forecast instead of 5-day.
* Added sunrise and sunset to forecast.

#### 2017-08-09
* Added notifications feature. Current temperature is notified every 30min.

#### 2017-07-04
* If only one city is found it will continue directly to the forecast, skipping the options menu.
* If you make a typo or the city is wrong, it will return to the main menu.
* Main menu now is the search menu.
* Added wind to the daily forecasts.

#### 2017-06-23
* If the city name has a space in it, add underscore.
* If the city name has ÅÄÖ or ÆØÅ in it, change it to OAA.

#### 2017-06-21
* Added gust and bearing
* If you quit you will be asked to search for a new location instead of being shown the previous search results.

#### 2017-06-19
* Added UV Index for current forecast with level indicator.
* Added humidity for current forecast.
* Added precipitation forecast for the 5-day forecast.

#### 2017-06-09
* Added ability to fetch coordinates from [Mapbox](https://www.mapbox.com) instead of having to look them up manually and add them to a (CSV) list. (You need an API key from Mapbox)

#### 2017-05-11
* If you had no API key and answer no it would loop, fixed.
* If you typed, ie, ee it would continue and bug out, fixed.
* Optimised sed with -r.

#### 2017-05-08
* Forecast is created with the help of arrays instead of repeating variables.

#### 2017-05-03
* Removed weekly summary as it stretched into the week after. Instead I added precipitation probability.

#### 2017-05-01
* Added more info on the main forecast, current, today and tomorrow.

#### 2017-04-29
* Added 5-day forecast view (without update, just using last fetched data).

#### 2017-04-28
* Added today's summary, week's summary and, sunrise and sunset.

#### 2017-04-23
* Added a CVS list of locations and menu.
