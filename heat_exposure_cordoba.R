# =============================================================================
# Heat exposure in Cordoba, Colombia: exploratory analysis of daily temperature
# Cities: Monteria and Sahagun | Period: 2000-2025
# Author: Rafael Andres Bracamonte Vega (PhD student, Universidad de los Andes)
# Data: ERA5 reanalysis through the Open-Meteo Historical Weather API
#       (https://open-meteo.com/en/docs/historical-weather-api) - free, no key
#
# How to run: open this file in RStudio, then
#   Session > Set Working Directory > To Source File Location
# and click "Source" (or run line by line with Ctrl+Enter).
# =============================================================================

# 0. Packages ------------------------------------------------------------------
pkgs <- c("jsonlite", "dplyr", "lubridate", "ggplot2", "readr")
missing_pkgs <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing_pkgs) > 0) install.packages(missing_pkgs)

library(jsonlite)
library(dplyr)
library(lubridate)
library(ggplot2)
library(readr)

dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

# 1. Locations and study period -------------------------------------------------
cities <- data.frame(
  city = c("Monteria", "Sahagun"),
  lat  = c(8.75, 8.95),
  lon  = c(-75.88, -75.44)
)
start_date <- "2000-01-01"
end_date   <- "2025-12-31"

# 2. Download daily temperature (ERA5 via Open-Meteo) ---------------------------
get_daily <- function(city, lat, lon) {
  url <- paste0(
    "https://archive-api.open-meteo.com/v1/archive",
    "?latitude=", lat, "&longitude=", lon,
    "&start_date=", start_date, "&end_date=", end_date,
    "&daily=temperature_2m_max,temperature_2m_mean,apparent_temperature_max",
    "&timezone=America%2FBogota"
  )
  res <- fromJSON(url)
  data.frame(
    city  = city,
    date  = as.Date(res$daily$time),
    tmax  = res$daily$temperature_2m_max,       # daily maximum air temperature (C)
    tmean = res$daily$temperature_2m_mean,      # daily mean air temperature (C)
    atmax = res$daily$apparent_temperature_max  # daily maximum "feels like" temperature (C)
  )
}

temp <- bind_rows(lapply(seq_len(nrow(cities)), function(i) {
  message("Downloading ", cities$city[i], " ...")
  get_daily(cities$city[i], cities$lat[i], cities$lon[i])
}))

write_csv(temp, "data/daily_temperature_cordoba.csv")

# 3. Cleaning and quality check -------------------------------------------------
summary(temp)
cat("Missing Tmax values:", sum(is.na(temp$tmax)), "\n")

temp <- temp %>%
  filter(!is.na(tmax)) %>%
  mutate(
    year  = year(date),
    month = factor(month.abb[month(date)], levels = month.abb)
  )

# 4. Hot days: Tmax above each city's 95th percentile (2000-2025) ---------------
thresholds <- temp %>%
  group_by(city) %>%
  summarise(p95_tmax = quantile(tmax, 0.95), .groups = "drop")
print(thresholds)

temp <- temp %>%
  left_join(thresholds, by = "city") %>%
  mutate(hot_day = tmax > p95_tmax)

# 5. Annual summary and linear trend --------------------------------------------
annual <- temp %>%
  group_by(city, year) %>%
  summarise(
    mean_tmax      = mean(tmax),
    max_atmax      = max(atmax, na.rm = TRUE),
    hot_days       = sum(hot_day),
    .groups = "drop"
  )
write_csv(annual, "data/annual_summary_cordoba.csv")

trends <- annual %>%
  group_by(city) %>%
  summarise(
    tmax_trend_C_per_decade     = 10 * coef(lm(mean_tmax ~ year))[2],
    hot_days_trend_per_decade   = 10 * coef(lm(hot_days ~ year))[2],
    .groups = "drop"
  )
print(trends)
write_csv(trends, "data/trends_cordoba.csv")

# 6. Figures --------------------------------------------------------------------
caption_txt <- "Data: ERA5 reanalysis via Open-Meteo. Analysis: R. Bracamonte"

# Fig 1. Seasonal cycle of daily maximum temperature
fig1 <- temp %>%
  group_by(city, month) %>%
  summarise(tmax = mean(tmax), .groups = "drop") %>%
  ggplot(aes(month, tmax, colour = city, group = city)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(title = "Seasonal cycle of daily maximum temperature, 2000-2025",
       x = NULL, y = "Mean daily Tmax (°C)", colour = NULL, caption = caption_txt) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")
ggsave("figures/fig1_seasonal_cycle.png", fig1, width = 8, height = 4.5, dpi = 300)

# Fig 2. Annual mean of daily maximum temperature, with linear trend
fig2 <- ggplot(annual, aes(year, mean_tmax, colour = city)) +
  geom_line(linewidth = 0.8) +
  geom_smooth(method = "lm", se = TRUE, linetype = "dashed", formula = y ~ x) +
  labs(title = "Annual mean of daily maximum temperature",
       x = NULL, y = "Mean daily Tmax (°C)", colour = NULL, caption = caption_txt) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")
ggsave("figures/fig2_annual_tmax_trend.png", fig2, width = 8, height = 4.5, dpi = 300)

# Fig 3. Number of hot days per year (Tmax > local 95th percentile)
fig3 <- ggplot(annual, aes(year, hot_days, fill = city)) +
  geom_col(position = "dodge") +
  labs(title = "Hot days per year (daily Tmax above the local 95th percentile)",
       x = NULL, y = "Number of hot days", fill = NULL, caption = caption_txt) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")
ggsave("figures/fig3_hot_days_per_year.png", fig3, width = 8, height = 4.5, dpi = 300)

# Fig 4. Distribution of daily maximum apparent temperature by month
fig4 <- ggplot(temp, aes(month, atmax, fill = city)) +
  geom_boxplot(outlier.size = 0.4) +
  labs(title = "Daily maximum apparent (\"feels like\") temperature by month",
       x = NULL, y = "Apparent Tmax (°C)", fill = NULL, caption = caption_txt) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")
ggsave("figures/fig4_apparent_temperature_by_month.png", fig4, width = 9, height = 4.5, dpi = 300)

message("Done. Check the 'data' and 'figures' folders.")
