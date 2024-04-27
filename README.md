# Prolog Adventure
| Room 1                   | Room 2                        | Room 3   | Room 4               | Room 5       | Room 6  | Room 7           | Room 8 | Room 9               | Room 10    |
|--------------------------|-------------------------------|-----------|-----------------------|---------------|---------|-------------------|--------|----------------------|-------------|
| Items: Shotgun, Flashlight| Choose to kill or save enemy | Dark Room | Ammo Recharge Station | Item: Crowbar | Granny  | Item: Escape Key  |        | Ammo Recharge Station| Escape Room |

## Room 1:
Items Available: Flashlight, Shotgun
Note: You can only carry one item at a time. 
## Room 2:
Description: Choose to kill/save enemy
## Room 3:
Description: A dark room that requires the use of a flashlight to navigate.
Special Rule: You must have the flashlight from room1 to enter this room. Once you enter, you will drop the flashlight to keep the room lit for future adventurers.
## Room 4:
Description: Ammo Recharge Station
## Room 5:
Item Available: Crowbar
Note: If you already have an item from a previous room, you will drop it here to pick up the crowbar. You can only carry one item at a time.
## Room 6:
Obstacle: Granny - Ghost
Description: This room is haunted by Granny blocking your path.
Solution: You must have the shotgun from room1 to enter this room and eliminate Granny. Once you shoot Granny, she will stay dead, allowing you to proceed.
## Room 7:
Challenge: Locked Box containing the escape key
Special Rule: You will need the crowbar from room5 to open the locked box and retrieve the escape key.
## Room 8:
Description: A room with no items or obstacles, connecting you to the final escape room.
## Room 9:
Description: Ammo Recharge Station
## Room 10:
Objective: Escape!
Special Rule: Once you have the escape key from room7, make your way to room10 to unlock the door and finally escape from the building.

## TODO:
## Sukanya
- [x] Basic Implementation: 
  - Flashlight, Shotgun available in room1. 
  - Can pickup either (not both). 
  - Granny in room 6 - needs shotgun to enter. 
  - Escape Key in room 7. Can pickup and escape
- [x] Shotgun with ammo - kills granny only if ammo present, else player gets killed
  - Put in recharge spots for shotgun (following previous constraint)
- [x] Use of Knowledge Base
  - In room2 player has to choose either Foo/Bar - Program randomly assigns foo/bar as enemy.
  - If the player chooses the foe, then player has to restart, else the player can proceed with the game
  - The player only has to choose the first time he enters room2, other time (if the player returns to room2), then no choice necessary

## John
- [x] Additional Implementation:
-   - Ability to drop items into different rooms. 
- [x] Create another obstacle : Dark Room (room 3) - will need flashlight to enter (once lit - set tru and remains lit)
- [x] Create an item for pickup - crowbar at position 5. Addiditonal constraint - will need crowbar to open box with key at position 10

## Aiden
- [x] Specify Granny patrol rooms:
  - Walks randomly
  - Once killed in one room, revive in another
  
