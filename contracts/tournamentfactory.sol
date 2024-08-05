pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./tournament.sol";

contract TournamentManager  is ERC20, ERC20Burnable, Ownable{
    address[] public tournaments;
    mapping(address => bool) public isTournament;

    event TournamentCreated(address tournamentAddress, string name, uint256 startTime, uint256 endTime);
    event TournamentEdited(address tournamentAddress, string name, uint256 startTime, uint256 endTime);

    function createTournament(
        string _name,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        Tournament newTournament = new Tournament(_name, _startTime, _endTime, msg.sender);
        tournaments.push(address(newTournament));
        isTournament[address(newTournament)] = true;

        emit TournamentCreated(address(newTournament), _name, _startTime, _endTime);
    }

    function editTournament(
        address _tournamentAddress,
        string _name,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        require(isTournament[_tournamentAddress], "Not a valid tournament");
        Tournament tournament = Tournament(_tournamentAddress);
        require(msg.sender == tournament.owner(), "Not the tournament owner");

        tournament.editTournament(_name, _startTime, _endTime);

        emit TournamentEdited(_tournamentAddress, _name, _startTime, _endTime);
    }

    function getTournaments() public view returns (address[]) {
        return tournaments;
    }
}
