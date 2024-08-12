pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./matchs.sol";

// cos bn tran dau
// dau loai truc tiep
// set nhanh (random)

// một trận đấu được tạo ra với mục đích gì
// một trận đấu sẽ gồm bao nhiêu người
// Tầm bao nhiêu người sẽ bắt đầu 1 trận đấu được


contract Tournament is AccessControl,Ownable(msg.sender){
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant REFEREE_ROLE = keccak256("REFEREE_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    struct TournamentInfo{
        uint256 startTime;
        uint256 endTime;
        uint256 fee;
        bool start;
        bool completed;
    }

    Matchs matchs;
    TournamentInfo public tournament;
    uint countPlayer;
    mapping(uint32 => address) public position;
    address[] public players;
    address public playerWinner;
    uint256 public randomnessRequestId;

    event TournamentStart(bool start);
    event PlayerJoined(address player);
    event TournamentInfoStart(uint256 startTime, uint256 endTime, uint256 fee, bool start, bool completed);
    event PlayerWinner(address winner);
    event UpdateTournament(uint startTime, uint endTime, uint fee, bool start, bool completed);

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _fee
    ) {
        require(_startTime <= block.timestamp, "Time error");
        require(_endTime > _startTime, "Time error");

        tournament = TournamentInfo( _startTime, _endTime, _fee, true, false);
        emit TournamentInfoStart( _startTime, _endTime, _fee, true, false);
    }

    //set role
    function setManager(address manager) external onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(MANAGER_ROLE, manager);
    }

    function setReferee(address referee) external onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(REFEREE_ROLE, referee);
    }

    function setTournament(uint256 _startTime, uint256 _endTime, uint256 _fee) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(tournament.startTime <= block.timestamp, "Tournament did not start");
        require(tournament.endTime > block.timestamp, "Tournament has aldready ended");
        
        tournament = TournamentInfo(_startTime, _endTime, _fee, true, false);

        emit UpdateTournament(_startTime, _endTime, _fee, true, false);
    }

    // //lấy ra tất cả người chơi của 1 Tournament
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    //Tham gia 1 trận đấu
    function joinMath(address player,uint32 randomNumber) public payable {
        require(block.timestamp < tournament.startTime, "Tournament has started");
        require(player != address(0),"Address error");
        _grantRole(PLAYER_ROLE, msg.sender);
        countPlayer++;
        uint32 _position = uint32(countPlayer + randomNumber);
        position[_position] = player;
        players.push(player);
        emit PlayerJoined(player);
    }

    //bắt đầu trận đấu,set mặc định chỉ admin mới tạo
    function startTournament() external onlyRole(DEFAULT_ADMIN_ROLE){
        require(tournament.startTime > block.timestamp, "Tournament has aldready started");
        tournament.start = true;
        emit TournamentStart(true);
    }

    //Thêm các bước khi di chuyển cờ
    function setMoves(uint32 matchId, uint32 move) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(tournament.startTime <= block.timestamp, "Tournament did not start");
        require(tournament.endTime > block.timestamp, "Tournament has aldready ended");
        matchs.setMoves(matchId, move);
    }

     function setGames(uint32 matchId, uint32 [] memory moves, uint32 result) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(tournament.startTime <= block.timestamp, "Tournament did not start");
        require(tournament.endTime > block.timestamp, "Tournament has aldready ended");
        matchs.setGames(matchId, moves,result);
    }

     function setMatchs(uint32 player1, uint32 player2) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(tournament.startTime <= block.timestamp, "Tournament did not start");
        require(tournament.endTime > block.timestamp, "Tournament has aldready ended");
        matchs.setMatch(player1, player2);
    }

    function setWinner(address player) external onlyRole(DEFAULT_ADMIN_ROLE){
        playerWinner = player;
        emit PlayerWinner(player);
    }
}
