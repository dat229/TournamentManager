pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

// mỗi match sẽ set thắng thua
// nếu hòa thì chưa kết thúc

contract Matchs is Ownable(msg.sender){
    struct Game{
        uint32[] moves; // lưu bước di chuyển
        uint32 result; // lưu kết quả: 1 :player1 win, draw, 2:player2 win
    }

    struct Match{
        uint32 player1;
        uint32 player2;
        Game [] games;
        bool checkComplated;
        uint32 lastMatchResult;
    }

    uint private matchid;
    mapping (uint matchId => Match) public matches;

    event PlayerMoves(uint32 move);
    event StartMatch(uint32 player1, uint32 player2);
    event PlayerWin(uint32 player);

    function setMoves(uint matchId, uint32 move) external  {
         require(matches[matchId].games.length > 0, "No game exists for this match.");
         matches[matchId].games[matches[matchId].games.length - 1].moves.push(move);
        emit PlayerMoves(move);
    }

    function setGames(uint matchId, uint32 [] memory moves, uint32 result ) external{
        require(result > 0 && result <= 3,"Wrong type of result");
        matches[matchId].games.push(Game(moves, result));
        if(result == 1){
            matches[matchId].lastMatchResult = matches[matchId].player1;
            matches[matchId].checkComplated = true;
            emit PlayerWin(matches[matchId].player1);
        }
        if(result == 3){
            matches[matchId].lastMatchResult = matches[matchId].player2;
            matches[matchId].checkComplated = true;
            emit PlayerWin(matches[matchId].player2);
        }
    }

    function setMatch( uint32 player1, uint32 player2) external   {
        require(player1 != 0 || player2 != 0 ,"The player's address is not available");
        require(player1 != player2,"An error has occurred");
        matchid++;
        matches[matchid].player1 = player1;
        matches[matchid].player2 = player2;
        emit StartMatch(player1, player2);
    }
}