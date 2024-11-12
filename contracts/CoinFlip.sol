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
        uint256 indexed gameId,
        address indexed initializer,
        address indexed opponent,
        uint256 betAmount
    );

    event GameAccepted(
        uint256 indexed gameId,
        uint256 pickingSide
    );

    event GameFinished(
        uint256 indexed gameId,
        bool outcome
    );

    event GameCancelled(
        uint256 indexed gameId
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

        address payable flipper;
        address payable opponent;

        if (game.pickingSide == 1) {
            require(msg.sender == game.initializer, "Only the predetermined picking side can flip the coin");
            flipper = payable(game.initializer);
            opponent = payable(game.opponent);
        } else if (game.pickingSide == 2) {
            require(msg.sender == game.opponent, "Only the predetermined picking side can flip the coin");
            flipper = payable(game.opponent);
            opponent = payable(game.initializer);
        } else {
            revert("Invalid picking side");
        }

        require(game.gameId != 0, "Game does not exist");
        require(game.status == GameStatus.STARTED, "Invalid game status");
        require(msg.sender == game.opponent, "Only the opponent can play");

        uint256 totalBetAmount = game.betAmount * 2;
        uint256 coinFlipResult = 2; // Static for testing purpose, should be random !!!!!!!!!!!

        if (coinFlipResult == _coinSide) {
            flipper.transfer(totalBetAmount);
            game.winner = flipper;
        } else {
            opponent.transfer(totalBetAmount);
            game.winner = opponent;
        }

        game.status = GameStatus.FINISHED;

        emit GameFinished(_gameId, game.winner != address(0));
    }
}