//user_info (temporary store user_info in the app, so that we don't need to reload again)
//remember to update these in case we update username and userimage

bool hasLoadedCredential = false;
String? userImageURL;
String? username;
String? userEmail;

void reset() {
  hasLoadedCredential = false;
  userEmail = null;
  userImageURL = null;
  userEmail = null;
}
