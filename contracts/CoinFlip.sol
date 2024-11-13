// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract CoinFlip {

    enum GameStatus {
        INITIALIZED,
        STARTED,
        FINISHED,
        CANCELLED
    }

    struct Game {
        uint256 gameId;
        address initializer;
        address opponent;
        uint256 betAmount;
        GameStatus status;
        uint256 pickingSide;
        address winner;
    }

    uint256 public totalGameCount;
    mapping(uint256 => Game) public allGames;

    event GameCreated(
        uint256 gameId,
        address indexed initializer,
        address indexed opponent,
        uint256 betAmount
    );

    event GameAccepted(
        uint256 gameId,
        uint256 pickingSide
    );

    event GameFinished(
        uint256 gameId,
        address indexed winner
    );

    // Create a new game (funds deposited by the initializer)
    function createGame(address _opponent) external payable {
        require(msg.value > 0, "Bet amount must be greater than 0");
        require(_opponent != msg.sender, "You cannot play against yourself");

        totalGameCount++;

        Game memory newGame = Game({
            gameId: totalGameCount,
            initializer: msg.sender,
            opponent: _opponent,
            betAmount: msg.value,
            status: GameStatus.INITIALIZED,
            pickingSide: 0,
            winner: address(0)
        });

        allGames[totalGameCount] = newGame;

        emit GameCreated(totalGameCount, msg.sender, _opponent, msg.value);
    }

    // Accept a game (rest of funds deposited by the opponent) & determine the picking side (randomly)
    function acceptGame(uint256 _gameId) external payable {
        Game storage game = allGames[_gameId];

        require(game.gameId != 0, "Game does not exist");
        require(game.status == GameStatus.INITIALIZED, "Invalid game status");
        require(msg.sender == game.opponent, "Only the designated opponent can play");
        require(msg.value == game.betAmount, "Bet amount must match the initializer's bet");

        game.pickingSide = 2; // Static for testing purpose, should be random !!!!!!!!!!!

        game.status = GameStatus.STARTED;

        emit GameAccepted(_gameId, game.pickingSide);
    }

    function flipCoin(uint256 _gameId, uint256 _coinSide) external {
        require(_coinSide == 1 || _coinSide == 2, "Invalid coin side");

        Game storage game = allGames[_gameId];
        require(game.gameId != 0, "Game does not exist");
        require(game.status == GameStatus.STARTED, "Invalid game status");

        address payable initializer = payable(game.initializer);
        address payable gameOpponent = payable(game.opponent);

        (address payable flipper, address payable opponent) = game.pickingSide == 1 
            ? (initializer, gameOpponent)
            : (gameOpponent, initializer);

        require(msg.sender == (game.pickingSide == 1 ? initializer : gameOpponent), 
            "Only the predetermined picking side can flip the coin");

        uint256 totalBetAmount = game.betAmount * 2;
        uint256 coinFlipResult = 2; // Static for testing purpose, should be random !!!!!!!!!!!

        address payable winner = coinFlipResult == _coinSide ? flipper : opponent;

        winner.transfer(totalBetAmount);

        game.winner = winner;
        game.status = GameStatus.FINISHED;

        emit GameFinished(_gameId, winner);
    }
}