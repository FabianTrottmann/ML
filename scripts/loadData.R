library(spotifyr)
library(tidyverse)
library(lubridate)
source(file = "customizedSpotifyFunction.R")

# create access token for dev account 
# (need to create dev account first on https://developer.spotify.com/)
Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') # enter spotify client id here
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') # enter spotify client secret here
access_token <- get_spotify_access_token()

german_Hip_Hop_Artists <- get_genre_artists(genre = "german hip hop",
                                            market = 'DE', limit = 50, offset = 0, access_token)

# get tracks and audio features of artists
mydataframe <- data.frame()
c <- 0
for(i in 1:nrow(german_Hip_Hop_Artists))
{
  c <- c + 1
  print(paste("about to load artist ", german_Hip_Hop_Artists$name[i]))
  print(paste("with id:", german_Hip_Hop_Artists$id[i]))
  
  # sleep within the iteration to load more data, otherwise we get blocked by spotify
  # sleep 1 sec in each iteration and in every 12th iteration sleep 5 sec once (sleep amount are empirical values)
  if(c < 12)
  {
    print(i)
    Sys.sleep(1)
  }else{
    c <- 0
    Sys.sleep(5)
  }
  
  artistDataFrame <- get_artist_audio_features_by_artist_id(
    german_Hip_Hop_Artists$name[i],
    german_Hip_Hop_Artists$id[i],
    include_groups = c("album", "single"))
  
  mydataframe <- rbind(mydataframe, artistDataFrame)
}


# get track popularity via get_track function
mydataframe$track_popularity <- NA

c <- 0
for (i in 1:nrow(mydataframe))
{
  c <- c + 1
  popularity <- get_track(mydataframe$track_id[i])$popularity
  mydataframe$track_popularity[i] <- popularity
  
  if(c == 100)
  {
    print(paste0("Popularity loaded for ", i," tracks! Take a break..."))
    Sys.sleep(5)
    c <- 0
  }
  
  if(i == nrow(mydataframe)) {print("Done!")}
}




# write data to rds files
write_rds(mydataframe, paste0("../data/audio_features_by_german_hiphop_", Sys.Date(), ".rds"))
write_rds(german_Hip_Hop_Artists, paste0("../data/german_rap_artists_", Sys.Date(), ".rds"))
