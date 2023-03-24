//now continue with display griddelegate
//user games could be split by 2 (cross axis)

//done with delete and trash logic

//List<Game> restorableDeletedGames = []; //this might be for restore all items you have just deleted
//if we escape a managed items session, this should be set to null
//so maybe it should be manage inside managed items instead of here
//but managed item is for each item, so it would be set to [] -> don't really work
//or should it be a part of manage games screen

//this is a bit complicated, but the whole purpose of this is to store multiple deleted items if we delete rapidly
//or does it really needed

//maybe we should manage the deletedGame inside the managedgameitem widget
//each time deleted we just need to return the deleted Game ->
//check if use has click on undo but a bool
//if yes then restore the array, make deletedGame null and not upload to trash
//if no then upload to trash and then make it null

//Game? deletedGame;
//List<Game> restorableDeletedGames = [];
//should have the same logic as deletedGames
//however, for each add, we should check using contains if we add the same elements
//is this necessary though???s
//maybe not, but we should empty deletedGames after the Scaffold Messenger stops showing

//remember to use future delay to delete a game from deleted Game (make it null since it's now a Game not a List)
//if we go pass the time the scaffold messenger shows to the user.

//maybe like this, we use deletedGame as Game instead of list of Game
//then Scaffold Messenger should hide the previous one
//so we can only undo one item each time.
//however, the restoreable deleted one can store multiple games
//and we can also go to a page to see it, should have a button at that page and also at the managed page screen to restore all
//just like trash
//should use something like a timestamp (store data in Firebase or sqlite and maybe use Stored Preference)
//check timestamp on each startup to see if it passes 30 days, if so
//delete
//maybe after deleting associates each deleted items with a time stamp and store them on a Map array for deleted items in Firebase
//then on each startup compare their their timestamp with the timestamp of our app, if go pass the time stamp, then delete them
//yay

//int gamesGridFutureBuilderCounter = 0;

bool isFetchUserGames = false;
bool isFetchTrendingGames = false;

int managedItemTipsCounter1 = 0; //show a tip for every n touches
int managedItemTipsCounter2 = 0;
int trashItemTipsCounter = 0;

void reset() {
  //deletedGame = null;
  //restorableDeletedGames = [];
  //set these two there initial values to avoid the next user logging and see a brief data of the previous user
  isFetchTrendingGames = false;
  isFetchUserGames = false;
  //isFetchTrendingGames = false;
  managedItemTipsCounter1 = 0;
  managedItemTipsCounter2 = 0;
  trashItemTipsCounter = 0;
}
