# Videogames backlog project

Hi, I'm Hieu Tran, at UT Dallas. I am a Junior - Senior Computer Science student, and currently I am learning to become a good mobile developer.
This project is a joy of mine and I spent a whole month only working on it; I did sacrifice a bit of my GPA for this one.

This application uses Cloud Firestore and Firebase Storage as its database.
Application feature:
- Implement navigation the right way so that it is guaranteed that the page stack would not grow significantly in size, so the number of pages are almost constantly and low during each user's usage => improving performance.
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
- Favorite, Dislike, and Wishlist feature, with Wishlist feature reflecting on UI instantly (unwishlisted game would disappear immediately)
- Show Menu: implement a recursive showMenuHelper function to reflect user changes immediately
- Search Implementation: many screens have showSearch function
- Checking duplicates: adding a trending game must go through a check duplicates process (duplicates in your backlog and also in trash folder), and there would be many options: whether to remove duplicates, or keep them.
- Carousel Slider and Swipe Image Gallery:
  + These two widget/function work in tandem with each other
  + Game Images are displayed using carousel slider
  + If you want to see an image from Carousel Slider, clicking on it would lead to the correct image displayed by Swipe Image Gallery
- Sliver appbar that is a part of the Scroll View
  + Game's title image would disappear when scrolling down
  + Game's title's text has a border to improve visibility


*** Difficulty met during making this project:
- Navigation the right way so that the stack for pages would not grow in size (improve app's performance), and also log out function would work correctly (hasData = false).
  + Troubles when navigating from the appdrawer: solution is to use pushAndRemoveUntil with is route first route predicate.
  + Do not use pushReplacement to replace the appdrawer or push for appdrawer navigation since the stack would grow significantly)
  + while canPop -> pop, then push also works, but would briefly show previous pages
  + trouble with navigation and log out function (cannot actually logout from homescreen if navigating the wrong way)
 - Troubles fetching user preferences and implement user preferences (filters, theme, ...) at startup
  + Solution: fetch user preferences in main, and then pass it to ChangeNotifier classes constructors
 - Implement wishlist
 - Implement checking duplicates for a trending game
 - Use correct Firebase Storage and Cloud Firestore rules so that users can only modify their data without access to others'
 - Implement AppCheck: currently disabled


