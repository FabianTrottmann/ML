get_artist_audio_features_by_artist_id <- function (artist_name, artist_id = NULL, include_groups = "album", return_closest_artist = TRUE, 
                                                   dedupe_albums = TRUE, authorization = get_spotify_access_token()) 
{
  artist_albums <- get_artist_albums(artist_id, include_groups = include_groups, 
                                     include_meta_info = TRUE, authorization = authorization)
  num_loops_artist_albums <- ceiling(artist_albums$total/20)
  if (num_loops_artist_albums > 1) {
    artist_albums <- map_df(1:num_loops_artist_albums, function(this_loop) {
      get_artist_albums(artist_id, include_groups = include_groups, 
                        offset = (this_loop - 1) * 20, authorization = authorization)
    })
  }
  else {
    artist_albums <- artist_albums$items
  }
  artist_albums <- artist_albums %>% rename(album_id = id, 
                                            album_name = name) %>% mutate(album_release_year = case_when(release_date_precision == 
                                                                                                           "year" ~ suppressWarnings(as.numeric(release_date)), 
                                                                                                         release_date_precision == "day" ~ year(as.Date(release_date, 
                                                                                                                                                        "%Y-%m-%d", origin = "1970-01-01")), 
                                                                                                         TRUE ~ as.numeric(NA)))
  if (dedupe_albums) {
    artist_albums <- dedupe_album_names(artist_albums)
  }
  album_tracks <- map_df(artist_albums$album_id, function(this_album_id) {
    album_tracks <- get_album_tracks(this_album_id, include_meta_info = TRUE, 
                                     authorization = authorization)
    num_loops_album_tracks <- ceiling(album_tracks$total/20)
    if (num_loops_album_tracks > 1) {
      album_tracks <- map_df(1:num_loops_album_tracks, 
                             function(this_loop) {
                               get_album_tracks(this_album_id, offset = (this_loop - 
                                                                           1) * 20, authorization = authorization)
                             })
    }
    else {
      album_tracks <- album_tracks$items
    }
    album_tracks <- album_tracks %>% mutate(album_id = this_album_id, 
                                            album_name = artist_albums$album_name[artist_albums$album_id == 
                                                                                    this_album_id]) %>% rename(track_name = name, 
                                                                                                               track_uri = uri, track_preview_url = preview_url, 
                                                                                                               track_href = href, track_id = id)
  })
  dupe_columns <- c("duration_ms", "type", "uri", 
                    "track_href")
  num_loops_tracks <- ceiling(nrow(album_tracks)/100)
  track_audio_features <- map_df(1:num_loops_tracks, function(this_loop) {
    track_ids <- album_tracks %>% slice(((this_loop * 100) - 
                                           99):(this_loop * 100)) %>% pull(track_id)
    get_track_audio_features(track_ids, authorization = authorization)
  }) %>% select(-dupe_columns) %>% rename(track_id = id) %>% 
    left_join(album_tracks, by = "track_id")
  artist_albums %>% mutate(artist_name = artist_name, artist_id = artist_id) %>% 
    select(artist_name, artist_id, album_id, album_type, 
           album_images = images, album_release_date = release_date, 
           album_release_year, album_release_date_precision = release_date_precision) %>% 
    left_join(track_audio_features, by = "album_id") %>% 
    mutate(key_name = pitch_class_lookup[key + 1], mode_name = case_when(mode == 
                                                                           1 ~ "major", mode == 0 ~ "minor", TRUE ~ 
                                                                           as.character(NA)), key_mode = paste(key_name, mode_name))
}
