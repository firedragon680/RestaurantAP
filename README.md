# RestaurantAP
This is a game I'm working on for the Archipelago Game Jam. It may not get finished in time, or look pretty when it gets submitted, but I'm coding nonetheless

The main gameplay of this game is putting together food based on the customers' orders. Based on what world your restaurant is in, you will get different customers with different behaviors. Make them as happy as possible to increase your star rating in that world. Once you get 5* ratings in all worlds, you win! 

Title pending. "RestaurantAP" is ok but it doesn't give the right feeling to me

> [!NOTE]
> The details described below are not necessarily implemented yet, but are in my plans for the jam.

## Items
As this is an archipelago game, naturally, some things will be randomized into the multiworld. These include:

- Worlds your restaurant has access to
- Recipes 
- Ingredients 
- Kitchen equipment and upgrades
- Traps

## Locations
You may find items from this or other games in the multiworld upon doing these things:

- Earning a specific grade for the day in a world at a specific star ranking
  - An F to S grading system is used (F, D, C, B, A, S)
  - If you get a higher ranking, the lower ranking locations are automatically checked as well.
  - Ex: Earning a C for the day in "World 1" at 1* rank will give you the locations "World 1 - 1* - C", "World 1 - 1* - D", and "World 1 - 1* - F"
- Upgrading a world's star ranking
  - This requires obtaining an S rating for the day.
- (customer type) leaves with max happiness
  - Each distinct customer type gets their own location. 
