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
        uint256 createdAt;
    }

    uint256 public totalGameCount;
    uint256 public totalFinishedGameCount;
    mapping(uint256 => Game) public allGames;
    uint256 public constant GAME_EXPIRATION_TIME = 1 days;

    event GameCreated(
        uint256 gameId,
        address indexed initializer,
        address indexed opponent,
        uint256 betAmount,
        uint256 createdAt
    );

    event GameAccepted(
        uint256 gameId,
        uint256 pickingSide
    );

    event GameFinished(
        uint256 gameId,
        address indexed winner
    );

    event GameCancelled(
        uint256 gameId
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
            winner: address(0),
            createdAt: block.timestamp
        });

        allGames[totalGameCount] = newGame;

        emit GameCreated(totalGameCount, msg.sender, _opponent, msg.value, block.timestamp);
    }

    // Accept a game (rest of funds deposited by the opponent) & determine the picking side (randomly)
    function acceptGame(uint256 _gameId) external payable {
        Game storage game = allGames[_gameId];

        address payable initializer = payable(game.initializer);
        address payable opponent = payable(game.opponent);

        require(game.gameId != 0, "Game does not exist");
        require(game.status == GameStatus.INITIALIZED, "Invalid game status");
        require(msg.sender == opponent, "Only the designated opponent can play");
        require(msg.value == game.betAmount, "Bet amount must match the initializer's bet");

        game.pickingSide = getRandomSide(initializer, opponent);

        game.status = GameStatus.STARTED;

        emit GameAccepted(_gameId, game.pickingSide);
    }
    
    // Flip the coin (only the predetermined picking side can flip the coin)
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
        uint256 coinFlipResult = getRandomSide(initializer, gameOpponent);

        address payable winner = coinFlipResult == _coinSide ? flipper : opponent;

        winner.transfer(totalBetAmount);

        game.winner = winner;
        game.status = GameStatus.FINISHED;

        totalFinishedGameCount++;
        emit GameFinished(_gameId, winner);
    }

    // Cancel a game (only the initializer can cancel the game if it has expired and hasn't been accepted yet)
    function cancelGame(uint256 _gameId) external {
        Game storage game = allGames[_gameId];
        require(game.gameId != 0, "Game does not exist");
        require(game.status == GameStatus.INITIALIZED, "Invalid game status");
        require(block.timestamp >= game.createdAt + GAME_EXPIRATION_TIME, "Game has not expired yet");
        require(msg.sender == game.initializer, "Only the initializer can cancel the game");

        payable(game.initializer).transfer(game.betAmount);

        game.status = GameStatus.CANCELLED;

        emit GameCancelled(_gameId);
    }

    function getRandomSide(address initializer, address opponent) internal view returns (uint256) {
        
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            initializer,
            opponent
        )));

        return (randomNumber % 2) + 1;
    }
}