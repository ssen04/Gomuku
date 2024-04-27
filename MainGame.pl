% Define rooms and their respective properties
initialize_rooms :-
    retractall(room(_, _, _)),
    assertz(room(room1, [flashlight, shotgun], 'Items Available: Flashlight, Shotgun')),
    assertz(room(room2, [], 'Description: Guess your friend! If you choose enemy, then you have to restart')),
    assertz(room(room3, [], 'Description: This room is empty.')),
    assertz(room(room4, [ammo], 'Description: This room has ammo recharge/pickup station - one at a time.')),
    assertz(room(room5, [crowbar], 'Item(s) Available: Crowbar.')),
    assertz(room(room6, [], 'You must have killed the Obstacle: Granny (It wanders!) - Ghost with your shotgun!')),
    assertz(room(room7, [], 'Challenge: There is a locked chest!')),
    assertz(room(room8, [], 'Description: This room serves as a simple passage to the next challenge. There are no items or obstacles here.')),
    assertz(room(room9, [ammo], 'Description: This room has ammo recharge/pickup station - one at a time.')),
    assertz(room(room10, [], 'Objective: Escape!\nSpecial Rule: Once you have the escape key from room7, make your way to room10 to unlock the door and finally escape from the building.')).

% Define the adjacent rooms
isAdjacent(room1, room2).
isAdjacent(room2, room1).
isAdjacent(room2, room3).
isAdjacent(room3, room2).
isAdjacent(room3, room4).
isAdjacent(room4, room3).
isAdjacent(room4, room5).
isAdjacent(room5, room4).
isAdjacent(room5, room6).
isAdjacent(room6, room5).
isAdjacent(room6, room7).
isAdjacent(room7, room6).
isAdjacent(room7, room8).
isAdjacent(room8, room7).
isAdjacent(room8, room9).
isAdjacent(room9, room8).
isAdjacent(room9, room10).
isAdjacent(room10, room9).

% Using Dynamic predicate to track player's current room and carried item
% source: https://www.swi-prolog.org/pldoc/man?predicate=dynamic/1
:- dynamic current_room/1.
:- dynamic carried_item/1.
:- dynamic num_ammo/1.
:- dynamic foe_killed/1.
:- dynamic character/2. % pred takes 2
:- dynamic room/1.
:- dynamic granny_location/1.
:- dynamic chest_open/1.

% Initialize player in room1 without any item
initialize :-
    initialize_rooms,
    retractall(current_room(_)),
    retractall(carried_item(_)),
    assertz(current_room(room1)),
    format('-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'),
    format('\n| Room 1                      | Room 2                       | Room 3    | Room 4                | Room 5        | Room 6   | Room 7           | Room 8  | Room 9                | Room 10     |'),
    format('\n| You are here                | Choose to kill or save enemy | Dark Room | Ammo Recharge Station | Item: Crowbar | Granny   | Item: Escape Key |         | Ammo Recharge Station | Escape Room |'),
    format('\n| Items: Shotgun, Flashlight  |                              |           |                       |               |          |                  |         |                       |             |'),
    format('\n-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'),
    format('\nYou are in Room 1\n'),
    assertz(foe_killed(false)),
    assertz(chest_open(false)),
    initialize_room2_characters,
    assertz(num_ammo(2)),
    retractall(granny_location(_)),
    assertz(granny_location(room6)),
    display_room_information(room1).

% Display room information
display_room_information(Room) :-
    room(Room, Items, Description),
    format('~w\n', [Description]),
    format('Items with can choose to take: ~w\n', [Items]),
    isAdjacent_rooms(Room, AdjacentRooms),
    format('Allowed moves: ~w\n', [AdjacentRooms]),
    % (carried_item(Item) -> format('Item carried: ~w\n', [Item]); true).
    (carried_item(Item) -> 
        (Item == shotgun -> 
            (num_ammo(Ammo) -> 
                format('Item carried: ~w\n', [Item]),
                format('Ammo remaining: ~w\n', [Ammo])
            ; 
                format('Item carried: ~w\n', [Item])
            )
        ;
            format('Item carried: ~w\n', [Item])
        )
    ;
        true
    ),
    % About Granny's location
    granny_location(GrannyRoom),
    format('\n** You feel something from ~w. Granny might be there?\n', [GrannyRoom]),
    true.

% Get isAdjacent rooms
isAdjacent_rooms(Room, AdjacentRooms) :-
    findall(AdjRoom, (isAdjacent(Room, AdjRoom), room(AdjRoom, _, _)), AdjacentRooms).

% Check if the user has a flashlight or if a specific room has a flashlight.
has_flashlight(Room) :-
    (
        carried_item(flashlight) ; % Check if the player is carrying the flashlight
        (room(Room, Items, _), member(flashlight, Items))
    ). 

% Handle dark room event; if the player has flashlight they can proceed with true, false otherwise
handle_dark_room(Room) :-
    has_flashlight(Room) -> % Check if carrying flashlight
        write('\nThe flashlight is turned on! The room is lit.\n')
    ;   write('\n\nThe room is too dark! You cannot progress forward to room3.\n\n'),
        false.

% Handle granny encounter event; if the player has shotgun and ammo they can proceed with true, false otherwise
handle_granny_encounter :-
    carried_item(shotgun), num_ammo(X), X > 0 -> % Check if carrying shotgun and num_ammo > 0
        write('\n** You encountered Granny and successfully killed it.\n'),
        retract(num_ammo(RemAmmo)), % Decrement num_ammo
        NewRemAmmo is RemAmmo - 1,
        assertz(num_ammo(NewRemAmmo)),
        revive_granny
    ;   write('\n** You entered the room without any ammo - Granny kills you!\n'),
        write('Game over. Resetting game...\n'),
        reset_game,
        false.

% Change the player's actual location
change_room(Room) :-
    retract(current_room(_)),
    assertz(current_room(Room)),
    write('--------------------------------------------------------------------------------'),
    format('\nMoved to ~w\n', [Room]),
    display_room_information(Room).

% Move to a new room and handle some events; dark room and Granny encounter
move(Room) :-
    move_granny,
    granny_location(GrannyRoom),
    current_room(CurrentRoom),
    (isAdjacent(CurrentRoom, Room) -> % Rooms should be isAdjacent as defined before for valid move
        % Check if moving to Grannys room
        (Room == GrannyRoom ->
            (handle_granny_encounter ->
                change_room(Room)
            )
        % Check if moving to room3
        ; Room == room3 -> 
            (handle_dark_room(Room) ->
                change_room(Room)
            )
        % Otherwise just move to a new room
        ; change_room(Room)
        )
    ; format('Invalid move!\n'),
    display_room_information(CurrentRoom)
    ).

% Pick up an item
pickup(Item) :-
    current_room(CurrentRoom),
    room(CurrentRoom, Items, Description),
    member(Item, Items),
    % Check that the user is not carrying an item. If so, they must drop it. 
    (carried_item(_) ->
        format('\n*****You are already carrying an item! You must drop it first before picking up a new one.*****\n'),
        display_room_information(CurrentRoom)
    ;
        % Delete the item that was picked up from the room
        delete(Items, Item, NewItems),
        retractall(room(CurrentRoom, _, _)),
        assertz(room(CurrentRoom, NewItems, Description)),
        retractall(carried_item(_)),
        assertz(carried_item(Item)),
        format('\nPicked up ~w\n', [Item]),
        display_room_information(CurrentRoom)
    ).

% Drop an item
drop(Item) :-
    carried_item(CarriedItem),
    current_room(CurrentRoom),
    (Item == CarriedItem ->
        room(CurrentRoom, Items, Description),
        retractall(room(CurrentRoom, _, _)),
        assertz(room(CurrentRoom, [Item | Items], Description)),
        retractall(carried_item(_)),
        format('\nDropped item ~w\n', [Item]),
        move_granny
    ;
        format('\n*****The item you are trying to drop is not the one you are carrying!*****\n')
    ),
    display_room_information(CurrentRoom).

% Recharge ammo
recharge :-
    current_room(CurrentRoom),
    (carried_item(shotgun) -> % Check if carrying shotgun
        (num_ammo(RemAmmo), RemAmmo < 2 -> % Check if carrying less than 2 ammo
            retract(num_ammo(RemAmmo)),
            NewAmmo is RemAmmo + 1,
            assertz(num_ammo(NewAmmo)),
            format('Recharged 1 ammo. Total ammo: ~w\n', [NewAmmo])
        ; 
            format('You can carry only 2 ammo at a time.\n')
        )
    ; 
        format('You need to carry a shotgun to recharge ammo.\n')
    ),
    display_room_information(CurrentRoom). % Display room information

% Break open the chest in room7
break_open_chest :-
    current_room(CurrentRoom),
    (carried_item(crowbar) -> % Check if carrying crowbar
        room(CurrentRoom, Items, Description),
        retractall(room(CurrentRoom, _, _)),
        format('\nYou broke open the chest using the crowbar!\n'),
        % assertz(room(CurrentRoom, [key | Items], 'Challenge: The chest has been broke open!')),
        assertz(room(CurrentRoom, [key | Items], Description)),
        assertz(chest_open(true))
    ; 
        format('\nThe chest is locked shut! You cannot open it.\n')
    ),
    display_room_information(CurrentRoom). % Display room information


% Briefly using KB
% Initialize characters in Room 2 and their relationships
initialize_room2_characters :-
    random_member(FooBar, [foo, bar]),
    (FooBar == foo -> 
        assertz(character(foo, foe)),
        assertz(character(bar, friend));
     FooBar == bar -> 
        assertz(character(foo, friend)),
        assertz(character(bar, foe))).

% Rule for player action and outcome
player_action(PChoice) :-
    member(PChoice, [foo, bar]),
    (
        (PChoice == foo, character(foo, foe)) -> 
            format('You killed ENEMY. You can proceed ...\n'),
            retract(foe_killed(_)),
            assertz(foe_killed(true))
    ;
        (PChoice == foo, character(foo, friend)) -> 
            format('You killed a friend and saved a foe. You have to restart from beginning ...\n'),
            reset_game
    ;
        (PChoice == bar, character(bar, foe)) -> 
            format('You killed ENEMY. You can proceed ...\n'),
            retract(foe_killed(_)),
            assertz(foe_killed(true))
    ;
        (PChoice == bar, character(bar, friend)) -> 
            format('You killed a friend and saved a foe. You have to restart from beginning ...\n'),
            reset_game
    ).

% Rule to reset the game
reset_game :-
    % Reset game state or return to the starting point
    format('Resetting game...\n'),
    % Add logic to reset game state or return to the starting point
    initialize_game_start.

% Initialize the game
initialize_game_start :-
    initialize_rooms,
    retractall(current_room(_)),
    retractall(carried_item(_)),
    retractall(foe_killed(_)),  % Reset foe killed state
    assertz(current_room(room1)),  % Set initial room to room1
    assertz(foe_killed(false)),   % Set foe killed state to false
    retractall(granny_location(_)),
    assertz(granny_location(room6)),
    format('Game initialized. You are in Room 1.\n').

% Main game loop
game_main_loop :-
    repeat,
    current_room(CurrentRoom), % Get current room
    (
        CurrentRoom == room1 -> 
        handle_room1(Command)
    ;
        CurrentRoom == room2 -> 
        handle_room2(Command)
    ;
        CurrentRoom == room3 -> 
        handle_room3(Command)
    ;
        CurrentRoom == room4 -> 
        handle_room4(Command)
    ;
        CurrentRoom == room5 -> 
        handle_room5(Command)
    ;
        CurrentRoom == room6 -> 
        handle_room6(Command)
    ;
        CurrentRoom == room7 -> 
        handle_room7(Command)
    ;
        CurrentRoom == room8 -> 
        handle_room8(Command)
    ;
        CurrentRoom == room9 -> 
        handle_room9(Command)
    ;
        CurrentRoom == room10 -> 
        handle_room10(Command)
    ;
        format('\nInvalid room.\n'),
        write('Enter command (move/pickup/drop/quit): '),
        read(Command) % Get action for invalid room
    ),
    execute_command(Command),
    (Command == quit ; is_goal_reached),
    !. % if command is quit - stop, else if goal is goal reached prevent from looping further - loop breaker

% Handle commands for room 1
handle_room1(Command) :-
    format('\nYou are currently in room 1\n'),
    write('Enter command (move/pickup/drop/quit): '),
    read(Command).

% Handle commands for room 2
handle_room2(Command) :-
    foe_killed(IsKilled),
    (
        \+ IsKilled ->
        write('--------------------------------------------------------------------------------'),
        format('\nYou are currently in room 2\n'),
        write('Choose to kill Foo (foo) or Bar (bar): '),
        read(Choice),
        player_action(Choice),
        Command = continue
    ;
        write('--------------------------------------------------------------------------------'),
        format('\nYou are currently in room 2\n'),
        write('Enter command (move/pickup/drop/quit): '),
        read(Command)
    ).

% Handle commands for room 3
handle_room3(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 3\n'),
    write('Enter command (move/pickup/drop/quit): '),
    read(Command).

% Handle commands for room 4
handle_room4(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 4\n'),
    write('Enter command (move/recharge/drop/quit): '),
    read(Command).

% Handle commands for room 5
handle_room5(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 5\n'),
    write('Enter command (move/pickup/drop/quit): '),
    read(Command).

% Handle commands for room 6
handle_room6(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 6\n'),
    write('Enter command (move/pickup/drop/quit): '),
    read(Command).

% Handle commands for room 7
handle_room7(Command) :-
    (chest_open(true) ->
        write('--------------------------------------------------------------------------------'),
        format('\nYou are currently in room 7\n'),
        write('Enter command (move/pickup/drop/quit): '),
        read(Command)
    ;
        write('--------------------------------------------------------------------------------'),
        format('\nYou are currently in room 7\n'),
        write('Enter command (move/open/drop/quit): '),
        read(Command)
    ).

% Handle commands for room 8
handle_room8(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 8\n'),
    write('Enter command (move/pickup/drop/quit): '),
    read(Command).

% Handle commands for room 9
handle_room9(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 9\n'),
    write('Enter command (move/recharge/drop/quit): '),
    read(Command).

% Handle commands for room 10
handle_room10(Command) :-
    write('--------------------------------------------------------------------------------'),
    format('\nYou are currently in room 10\n'),
    write('Enter command (move/pickup/drop/quit): '),
    read(Command).

% Execute command
execute_command(move) :-
    write('Enter room to move to: '),
    read(Room),
    move(Room).

execute_command(pickup) :-
    write('Enter item to pickup: '),
    read(Item),
    pickup(Item).

execute_command(drop) :-
    write('Enter item to drop: '),
    read(Item),
    drop(Item).

execute_command(recharge) :-
    write('Player at Recharge Station'),
    write('\n Recharging Ammo ...'),
    recharge.

execute_command(open) :-
    write('\nOpening chest...'),
    break_open_chest.

execute_command(quit) :-
    write('Quitting game.\n').

% Check if player reached the goal
is_goal_reached :- % goal is reached if player is in room 10 and is carrying the escape key with hiim
    current_room(room10), 
    carried_item(key),
    format('Congratulations! You have escaped!\n'),
    true.

% Granny patrols randomly; move to a new room or stay 
move_granny :-
    granny_location(CurrentGrannyRoom),
    findall(AdjRoom, isAdjacent(CurrentGrannyRoom, AdjRoom), AdjRooms),
    append(AdjRooms, [CurrentGrannyRoom], PossibleRooms), % To make Granny stay, include current location to possible rooms
    random_member(NewRoom, PossibleRooms),
    retract(granny_location(_)),
    assertz(granny_location(NewRoom)).

% Granny revives at any location if killed
revive_granny :-
    findall(Room, room(Room, _, _), Rooms),
    random_member(NewRoom, Rooms),
    retractall(granny_location(_)),
    assertz(granny_location(NewRoom)),
    write('** Granny has revived somewhere. Beware!\n').
