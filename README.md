# Heat exposure in Córdoba, Colombia

Exploratory analysis of daily temperature in **Montería** and **Sahagún** (Córdoba, Colombian Caribbean), 2000–2025.

This is a first learning project in R, built as a starting point for linking urban heat exposure with health outcomes in warm-humid Colombian cities. It is part of my preparation for PhD research at Universidad de los Andes (CIIA) on urban heat, thermal justice and social housing.

## Why

Extreme heat is a growing public health threat in Caribbean Colombian cities, but local evidence linking heat exposure to health outcomes is still scarce. Describing how hot these cities are, when and how often extreme heat occurs is the first step towards studying its health effects.

## Data

- **Temperature:** ERA5 reanalysis, retrieved through the [Open-Meteo Historical Weather API](https://open-meteo.com/en/docs/historical-weather-api) (free, no API key).
- Daily variables: maximum, mean and maximum apparent ("feels like") temperature at 2 m.
- Grid points: Montería (8.75 N, 75.88 W) and Sahagún (8.95 N, 75.44 W).

Note: ERA5 is a ~25 km reanalysis grid, so it does not capture intra-urban differences such as the urban heat island. It tends to underestimate local station maxima.

## Methods

1. Download daily data for both cities.
2. Basic cleaning and quality checks (missing values, summary statistics).
3. Define **hot days** as days with maximum temperature above each city's 95th percentile for 2000–2025.
4. Annual summaries and simple linear trends (°C per decade, hot days per decade).
5. Descriptive figures with `ggplot2`.

## Outputs

| Figure | Content |
|---|---|
| `figures/fig1_seasonal_cycle.png` | Seasonal cycle of daily maximum temperature |
| `figures/fig2_annual_tmax_trend.png` | Annual mean Tmax with linear trend |
| `figures/fig3_hot_days_per_year.png` | Hot days per year |
| `figures/fig4_apparent_temperature_by_month.png` | Apparent temperature by month |

Tables are saved in `data/` (daily data, annual summary, trends).

## How to run

1. Install [R](https://cran.r-project.org/) and [RStudio](https://posit.co/download/rstudio-desktop/).
2. Open `heat_exposure_cordoba.R` in RStudio.
3. `Session > Set Working Directory > To Source File Location`.
4. Click **Source**. Missing packages are installed automatically.

## Next steps

- Link heat exposure with health outcomes using Colombian open data: DANE vital statistics (deaths by ICD-10 cause, e.g. cardiovascular I00–I99) and RIPS health service records (e.g. mental health, F codes).
- Harmonize climate, health and census data at municipality–week level.
- Explore lagged and non-linear heat–health associations (e.g. distributed lag non-linear models, DLNM).
- Move from reanalysis to higher-resolution data (land surface temperature, local stations) to study intra-urban heat exposure.

## Author

Rafael Andrés Bracamonte Vega — PhD student in Engineering, Universidad de los Andes (CIIA), Colombia.
