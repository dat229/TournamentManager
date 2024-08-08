
pragma solidity >=0.8.2 <0.9.0;

contract Tournament {
    string public name;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public fee;
    address[] private _players;
    address public winner;
    bool public completed;
    address public owner;
    
    uint256 public randomnessRequestId;

    event PlayerJoined(address player);
    event WinnerSet(address winner);
    event TournamentEdited(string name, uint256 startTime, uint256 endTime, uint256 fee);
    event WinningsWithdrawn(address winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(
        string memory _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _fee
    ) {
        name = _name;
        startTime = _startTime;
        endTime = _endTime;
        fee = _fee;
        winner = address(0);
        completed = false;
        owner = msg.sender;
    }


    function players() public view returns (address[] memory) {
        return _players;
    }

    function joinTournament() public payable {
        require(block.timestamp < startTime, "Tournament has started");
        require(msg.value == fee, "Incorrect fee");

        _players.push(msg.sender);
        emit PlayerJoined(msg.sender);
    }

    function setWinner(address _winner) public onlyOwner {
        require(block.timestamp > endTime, "Tournament not ended");
        require(!completed, "Tournament already completed");

        winner = _winner;
        completed = true;
        emit WinnerSet(_winner);
    }

    function editTournament(
        string memory _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _fee
    ) public onlyOwner {
        name = _name;
        startTime = _startTime;
        endTime = _endTime;
        fee = _fee;
        emit TournamentEdited(_name, _startTime, _endTime, _fee);
    }

    function withdrawWinnings() public {
        require(completed, "Tournament not completed");
        require(winner == msg.sender, "Not the winner");

        uint256 prizeAmount = address(this).balance;
        require(prizeAmount > 0, "No winnings to withdraw");
        
        payable(msg.sender).transfer(prizeAmount);
        emit WinningsWithdrawn(msg.sender, prizeAmount);
    }

    function setRandomnessRequestId(uint256 _requestId) public onlyOwner {
        randomnessRequestId = _requestId;
    }
}