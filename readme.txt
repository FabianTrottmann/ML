# Spotify Analysis: Track duration of german rap music

## Scripts

Run in that order:

- customizedSpotifyFunction.R: customized function from {spotfiyr} package to get audio features from artist by artist_id (using artist_name gets data from wrong artist in some cases)
- loadData.R: gets the data via spotify api by using the {spotifyr} package (run only if new data is required, Spotify Developer account required)
- preprocessing.R: data cleaning and preparation, saves cleaned data to .rds file
- analysis.Rmd: loads cleaned .rds file, runs analysis (visual exploration and model fitting) 
- listOfFunctions.Rmd: create a html table of usefule R-functions seen during the R Bootcamp module.

## Remark on reproducibility

The data for this analysis has been downloaded on the 21.02.2020. The whole analysis can be reproduced with the same input data by running the **analysis.Rmd** script. However, if you wish to run the analysis with more recent data, you can run all the above mentioned scripts. In that case, the date in the filename on *preprocessing.Rmd* and *analysis.Rmd* has to be updated.

## Authors
Luca Hüsler, Fabian Trottmann