pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./tournament.sol";

contract TournamentManagers is AccessControl, Ownable(msg.sender) {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant REFEREE_ROLE = keccak256("REFEREE_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    address payable withdrawWallet;
    uint IdtournamentCount;
    uint countTournament;
    uint256 feeTournament;

    mapping (uint Idtournament => address) tournaments;
    mapping (uint countTournament => Tournament) public listTournament;

    event creatTournament(uint countTournament);
    event JoinTournament(uint countTournament, address player);
    event WithdrawAward(uint _tournamentId, address winner);
    
    constructor(){
        withdrawWallet = payable(msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    function setDrawWinnings(address payable _wallet) public {
        withdrawWallet = _wallet;
    }

    function setManagerTournament(uint _countTournament, address manager) public onlyOwner{
        listTournament[_countTournament].setManager(manager);
    }

    function setFee(uint256 _fee) public onlyOwner{
        feeTournament = _fee;
    }

    function setRefereeTournament(uint _countTournament, address referee) public onlyOwner{
       listTournament[_countTournament].setReferee(referee);
    }

    function setMoves(uint _countTournament,uint32 matchId, uint32 move) public onlyOwner{
        listTournament[_countTournament].setMoves(matchId,move);
    }

    function createNewTournament(uint startTime, uint endTime) public onlyOwner{
        require(feeTournament > 0, "Fees have not yet been established");
        countTournament++;
        Tournament newTournament = new Tournament(startTime, endTime, feeTournament);
        listTournament[countTournament] = newTournament;
        emit creatTournament(countTournament);
    }

     function editTournament(uint _tournamentId, uint newTimeStart, uint newTimeEnd) public onlyOwner{
        require(newTimeStart <= block.timestamp, "Time error");
        require(newTimeEnd > newTimeStart, "Time error");
        Tournament tournament = listTournament[_tournamentId];
        listTournament[_tournamentId].setTournament( newTimeStart, newTimeEnd, feeTournament);
    }

    function setMatchs(uint _tournamentId, uint32 player1, uint32 player2) public onlyOwner{
        listTournament[_tournamentId].setMatchs(player1, player2);
    }

    function joinTournament(uint _tournamentId, uint32 randomNumber ) public payable{
        require(feeTournament > 0, "Fees have not yet been established");
        require(msg.value == feeTournament, "transfer value did not match with fee");
        listTournament[_tournamentId].joinMath(msg.sender, randomNumber);
        
        emit JoinTournament(_tournamentId, msg.sender);
    }

    function setGames(uint _tournamentId, uint32 matchId, uint32 [] memory moves, uint32 result) public onlyOwner{
        listTournament[_tournamentId].setGames(matchId, moves,result);
    }

    function setStartTournament(uint _tournamentId) public view onlyOwner{
        listTournament[_tournamentId].startTournament;
    }

    //set winner
    function setWinner(uint _tournamentId, address _winner) public {
        address tournament = tournaments[_tournamentId];
        require(listTournament[_tournamentId].hasRole(keccak256("REFEREE_ROLE"), msg.sender), "Only referee can do this function");
        
        address[] memory players = listTournament[_tournamentId].getPlayers();
        bool checkPlayer = isPlayer(_winner,players);
        require(checkPlayer,"Player does not exist");

        listTournament[_tournamentId].setWinner(_winner);
    }

    //check player
    function isPlayer(address _addressToCheck,address[] memory players) public pure returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == _addressToCheck) {
                return true;
            }
        }
        return false;
    }


    function withdrawAward(uint _tournamentId, address winner) public onlyOwner{
        require(listTournament[_tournamentId].playerWinner() != address(0), "This tournament did not have winner");
        require(listTournament[_tournamentId].playerWinner() == winner, "This address are not winner of this tournament");

        uint countPlayer = listTournament[_tournamentId].getPlayers().length;
        
        uint totalAmount = countPlayer * feeTournament;
        uint fee = (totalAmount * 5) / 100;
        uint award = totalAmount - fee;

        payable(winner).transfer(award);
        emit WithdrawAward(_tournamentId,winner);
    }


    receive() external payable {}
    fallback() external payable {}
}
