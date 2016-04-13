# Forever Challenge
Please clone this project and create a branch with your changes that fulfill the requirements below.  If you need to make an assumption about a vague requirement, feel free to do so, but please state that assumption at the bottom of this Readme.  Try to fulfill all of the requirements as if this application is going to be deployed into the real world with heavy usage.


# Requirements
1. Add basic API actions (index, show, create, update and destroy) to the albums_controller and photos_controller.
2. The index route for photos should look like /album/:album_id/photos.
3. The API index actions should return JSON with all available fields for the record AND a field for the total number of records.
4. The API should use pagination with a max of 10 items per page and accept a param to iterate through pages.
5. When creating or updating a photo, ensure that the photo's url ends with the string ".jpeg" or ".jpg".
6. Ensure that no more than 60 photos can be added to an album.
7. Create a JSON controller action that can add multiple photos to an album at once.  This should be a POST to /album/:id/add_photos.
8. Ensure that the show action for photos returns the name and id for all the albums it belongs to.
9. Ensure that an album's average_date field is always the average taken_at date of all associated photos (or nil if the album has no photos).


# Bonus

1. Create a model and controller for videos.  This should be similar to photos in how it can be added to albums.  Albums should return a list of photos and videos.


# Tech Specs
Rails 4.2.6
SQLite preferred, Postgres OK
Anything can be changed if you think it's needed, including gemfile, database schema, configs, etc.


# Getting Started
Run `bundle install` and `rake db:migrate`.

You can populate your database with fake data by running `rake db:seed`.
