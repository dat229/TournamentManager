pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol"; 

contract Tournament is ERC20, ERC20Burnable, Ownable {
    string public name;
    uint256 public startTime;
    uint256 public endTime;

    address public owner;

    constructor(
        string _name,
        uint256 _startTime,
        uint256 _endTime,
        address _owner
    ) {
        name = _name;
        startTime = _startTime;
        endTime = _endTime;
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function editTournament(
        string _name,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyOwner {
        name = _name;
        startTime = _startTime;
        endTime = _endTime;
    }
}
