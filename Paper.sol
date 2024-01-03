
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract RockPaperScissors {
  
    address public player1;
    address public player2;
    // Declares two public addresses representing the players.

    uint256 public deadline;
    // Declares a public variable to store the deadline for moves submission.

    enum Move { None, Rock, Paper, Scissors }
    // Declares an enumeration representing the possible moves: None, Rock, Paper, Scissors.

    mapping(address => Move) public moves;
    // Declares a mapping to associate each player's address with their chosen move.

    event GameResult(address winner, Move move);
    // Declares an event that will be emitted when the game result is determined.

    modifier onlyPlayers() {
        require(msg.sender == player1 || msg.sender == player2, "You are not a player in this game");
        _;
    }
    // Declares a modifier to restrict certain functions to only the participating players.

    modifier gameNotStarted() {
        require(player1 == address(0) || player2 == address(0), "Game has already started");
        _;
    }
    // Declares a modifier to ensure that certain functions can only be called before the game starts.

    modifier gameInProgress() {
        require(player1 != address(0) && player2 != address(0), "Game has not started yet");
        _;
    }
    // Declares a modifier to ensure that certain functions can only be called when the game is in progress.

    modifier gameNotEnded() {
        require(block.timestamp < deadline, "Game has already ended");
        _;
    }
    // Declares a modifier to ensure that certain functions can only be called before the game deadline.

    constructor() {
        deadline = block.timestamp + 1 days; // Game expires in 1 day
    }
    // Constructor function that sets the initial value for the deadline, one day from contract deployment.

    function joinGame() external gameNotStarted {
        require(player1 != msg.sender, "You are already player1");
        require(player2 == address(0), "Game is full");

        player2 = msg.sender;
    }
    // Function allowing a player to join the game, assuming the game has not started and there's an available slot.

    function submitMove(Move move) external gameInProgress onlyPlayers gameNotEnded {
        require(moves[msg.sender] == Move.None, "You've already submitted your move");

        moves[msg.sender] = move;

        if (moves[player1] != Move.None && moves[player2] != Move.None) {
            determineWinner();
        }
    }
    // Function allowing players to submit their moves, as long as the game is in progress, the player has not submitted a move yet, and the game deadline has not passed.

    function determineWinner() internal {
        require(moves[player1] != Move.None && moves[player2] != Move.None, "Moves are not yet submitted");

        if (moves[player1] == moves[player2]) {
            emit GameResult(address(0), moves[player1]); // It's a tie
        } else if (
            (moves[player1] == Move.Rock && moves[player2] == Move.Scissors) ||
            (moves[player1] == Move.Paper && moves[player2] == Move.Rock) ||
            (moves[player1] == Move.Scissors && moves[player2] == Move.Paper)
        ) {
            emit GameResult(player1, moves[player1]);
        } else {
            emit GameResult(player2, moves[player2]);
        }

        // Reset the game
        player1 = address(0);
        player2 = address(0);
        moves[player1] = Move.None;
        moves[player2] = Move.None;
        deadline = block.timestamp + 1 days;
    }
    // Function to determine the winner based on the players' moves, emit the result event, and reset the game state.
}

