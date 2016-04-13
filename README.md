# Getting Started

### users
actions :show

name
email

has_many :albums
has_many :photos

### albums
user_id
description
position
averate_date

### photos
user_id
album_id
name
description
url
taken_at

# Challenge

1. Add basic API actions (index, show, create, update and destroy) to the albums_controller and photos_controller.
3. The index route for photos should look like /user/:user_id/photos.
4. The API index actions should return JSON with all fields for the record plus AND the total number of records.
5. The API should use pagination and accept a param to iterate through pages.
6. When creating or updating a photo, ensure that the photo's url ends with the string ".jpeg" or ".jpg".
7. Create a JSON controller action that can add multiple photos to an album.  This should be a POST to /album/:id/add_photos.
8. Ensure that the show action for photos returns the name and id for all albums.
9. Ensure that a user cannot add more than 60 photos to an album.
10. Ensure that an album's average_date field is always the average taken_at date of all associated photos (or nil if the album has no photos).

# Bonus

1. Create a model and API for videos.  This should be similar to photos in how it can be added to albums.
