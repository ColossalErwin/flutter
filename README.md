# Videogames backlog project
# My name is Hieu Tran (Luu)

This application uses Cloud Firestore and Firebase Storage as its database.
Application feature:
- Allow users to create a new video game for their backlog. Their are many ways to add a new game:
  + Users can add a trending game directly to their backlog without any user input. This feature is only available if a trending game has already been released. If it has not, then users can only wishlist it.
  + Using a form to fill a game basic information
  + Using IMDb: pass an IMDb url for a game so that the app can fetch its metadata and populate form's fields
- Managing images feature:
  + Users can upload images from their gallery or camera, or use Internet's image URLs. If images are added from files, then they are stored in Firebase Storage.
  + Users can manage these images by clicking on the edit button in mange games screen; if users delete some image URLs, not only they are deleted from Cloud Firestore, those that are stored from Firebase Storage are also permenantly removed.
- Dark mode:
  + Users can switch between dark mode and light mode
  + At startup, user preference for theme mode is fetched from the cloud, not from shared preferences (to avoid people using same devices)
- Changing information:
  + Users can update their avatar and username
  + Email cannot be changed since it's associated with your account
- Trash:
  + Remove trash after n month(s) feature: users can change their preference in settings
  + Restore a trash game/all trash games
- Carousel Slider and Swipe Image Gallery:
  + These two widget/function work in tandem with each other
  + Game Images are displayed using carousel slider
  + If you want to see an image from Carousel Slider, clicking on it would lead to the correct image displayed by Swipe Image Gallery
- Favorite, Dislike, and Wishlist feature, with Wishlist feature reflecting on UI instantly (unwishlisted game would disappear immediately)
- Show Menu: implement a recursive showMenuHelper function to reflect user changes immediately
- Search Implementation: many screens have showSearch function
- Checking duplicates: adding a trending game must go through a check duplicates process (duplicates in your backlog and also in trash folder), and there would be many options: whether to remove duplicates, or keep them.

