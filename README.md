# Forever Challenge
Please create a fork of this project and fulfill the requirements below.  Upon completion, please send Forever a link to your fork.

If you need to make an assumption about a vague requirement, feel free to do so, but please state that assumption at the bottom of this Readme.  Try to fulfill all of the requirements as if this application is going to be deployed into the real world with heavy usage.


# Requirements
1. Add basic API actions (index, show, create, update and destroy) to the albums_controller and photos_controller.
2. The albums index actions should return JSON with all available fields for the record AND a field for the total number of photos in the album.
3. The API index actions should use pagination with a max of 10 items per page and accept a param to iterate through pages.
4. An album's show action should return data for each photo in the album.
5. Ensure that every album has a name.
6. Ensure that every photo record belongs to an album, has a name and a url that ends with the string ".jpeg" or ".jpg".
7. Ensure that no more than 60 photos can be added to an album.
8. Create or modify a controller action so that multiple photos can be added to an album from one request.
9. Ensure that an album's average_date field is always the average taken_at date of all associated photos (or nil if the album has no photos).


# Bonus (only for senior developers)
1. Allow the API to add videos to an album.  The album index action should return a combination of photos and videos.
2. Allow photos to be added to multiple albums.


# Tech Specs
Rails 4.2.6

SQLite is preferred. Postgres is ok.

Anything can be changed if you think it's needed, including the gemfile, database schema, configs, etc.


# Getting Started
Run `bundle install` and `rake db:migrate`.

You can populate your database with fake data by running `rake db:seed`.

# ASSUMPTIONS
## General
1. Completely open API with no authentication or restriction
2. Specs should be written

## For Albums
1. Position is a physical presentation counter and must be updated when albums are created, updated (shifted), or destroyed
2. Upon destruction, clients will be able to identify which photos are affected without feedback from the API
3. the "no more than 60" rule applies to the sum of photo and video counts
4. When posting multiple photos/videos in a single request, they are to belong to the same album. Therefore, the POST is made to /albums/:album_id/:media_type

## For Photos
1. The actual transfer of binary photo/video data is handled separately. This API is only for the metadata surrounding the photos
2. Adding an existing photo to an existing album should be done through POST to /albums/:album_id/photos/:photo_id.  Removal using DELETE at the same path

## For Videos
1. Similar attributes and validations are required (from photos), with different file extension validations.
2. Adding existing videos to an album should follow the same pattern as for photos

