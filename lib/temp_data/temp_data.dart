bool isFetchUserGames = false;
bool isFetchTrendingGames = false;

int managedItemTipsCounter1 = 0; //show a tip for every n touches
int managedItemTipsCounter2 = 0;
int trashItemTipsCounter = 0;

void reset() {
  isFetchTrendingGames = false;
  isFetchUserGames = false;
  managedItemTipsCounter1 = 0;
  managedItemTipsCounter2 = 0;
  trashItemTipsCounter = 0;
}
