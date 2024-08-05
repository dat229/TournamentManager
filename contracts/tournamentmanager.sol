pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./tournamentfactory.sol";

contract TournamentManager  is ERC20, ERC20Burnable, Ownable{
     TournamentFactory public tournamentFactory;

    constructor() {
        tournamentFactory = new TournamentFactory();
    }

    function createTournament(
        string _name,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        tournamentFactory.createTournament(_name, _startTime, _endTime);
    }

    function editTournament(
        address _tournamentAddress,
        string _name,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        tournamentFactory.editTournament(_tournamentAddress, _name, _startTime, _endTime);
    }

    function getTournaments() public view returns (address[]) {
        return tournamentFactory.getTournaments();
    }
}