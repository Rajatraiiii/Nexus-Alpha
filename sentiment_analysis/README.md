# R Sentiment Analysis

A lightweight R project that provides a multi-domain sentiment analysis dashboard (Shiny).

## What this repo contains
- `app.R` — Shiny dashboard demonstrating sentiment analysis across sample datasets (IMDB, Twitter, Amazon, Reddit, News).

## Key packages used
This project uses the following R packages (loaded in `app.R`):
- shiny
- shinydashboard
- shinyjs
- shinycssloaders
- ggplot2
- dplyr
- tidyr
- tidytext
- stringr
- wordcloud2
- syuzhet
- scales
- DT
- forcats
- ggridges

Install missing packages in R with, for example:

```r
install.packages(c("shiny","shinydashboard","shinyjs","shinycssloaders",
                   "ggplot2","dplyr","tidyr","tidytext","stringr",
                   "wordcloud2","syuzhet","scales","DT","forcats","ggridges"))
```

## Run the app
- From R or RStudio: open `app.R` and click *Run App*.
- Or run from an R console:

```r
shiny::runApp('app.R')
```

## Notes
- This README is intentionally brief. If you want a longer README (usage examples, data sources, tests, or contribution guidelines), tell me what to include.

---

Recreated by request.