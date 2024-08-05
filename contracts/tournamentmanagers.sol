pragma solidity >=0.8.2 <0.9.0;

import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./tournament.sol";

contract TournamentManagers is Ownable {
    bytes32 internal keyHash;
    uint256 internal fee;

    // Random
    IVRFCoordinatorV2Plus internal vrfCoordinator;
    uint256 s_subscriptionId;
    uint16 internal requestConfirmations = 3;
    uint32 internal callbackGasLimit = 250000;
    uint32 internal numWords = 1;

    mapping(address => bool) public admins;
    mapping(address => bool) public referees;
    LinkTokenInterface internal LINK;

    mapping(uint256 => address) public tournaments;
    mapping(uint256 => uint256) public requestIdToTournamentId;
    uint256 public tournamentCount;

    event TournamentCreated(uint256 id, string name, uint256 startTime, uint256 endTime, uint256 fee);
    event TournamentEdited(uint256 id, string name, uint256 startTime, uint256 endTime, uint256 fee);
    event PlayerJoined(uint256 tournamentId, address player);
    event WinnerSet(uint256 tournamentId, address winner);
    event RefereeAdded(address referee);
    event RefereeUpdated(address referee);

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not the Admin");
        _;
    }

    modifier onlyReferee() {
        require(referees[msg.sender], "Not the referee");
        _;
    }

    constructor (
        address _VRFCoordinator,
        address _LinkToken,
        bytes32 _keyHash,
        uint256 _fee,
        uint256 subscriptionId
    ) Ownable(msg.sender) {
        admins[msg.sender] = true;
        keyHash = _keyHash;
        fee = _fee;
        LINK = LinkTokenInterface(_LinkToken);
        s_subscriptionId = subscriptionId;
        vrfCoordinator = IVRFCoordinatorV2Plus(_VRFCoordinator);
    }

    function setAdmin(address _admin, bool _isAdmin) public onlyOwner {
        admins[_admin] = _isAdmin;
    }

    function createTournament(
        string memory _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _fee
    ) public onlyAdmin {
        Tournament newTournament = new Tournament(_name, _startTime, _endTime, _fee);
        tournamentCount++;
        tournaments[tournamentCount] = address(newTournament);
        emit TournamentCreated(tournamentCount, _name, _startTime, _endTime, _fee);
    }

    function editTournament(
        uint256 _id,
        string memory _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _fee
    ) public onlyAdmin {
        Tournament tournament = Tournament(tournaments[_id]);
        tournament.editTournament(_name, _startTime, _endTime, _fee);
        emit TournamentEdited(_id, _name, _startTime, _endTime, _fee);
    }

    function joinTournament(uint256 _id) public payable {
        Tournament tournament = Tournament(tournaments[_id]);
        tournament.joinTournament{value: msg.value}();
        emit PlayerJoined(_id, msg.sender);
    }

    function withdrawWinnings(uint256 _id) public {
        Tournament tournament = Tournament(tournaments[_id]);
        tournament.withdrawWinnings();
    }

    function setReferee(address _referee, bool _isReferee) public onlyAdmin {
        referees[_referee] = _isReferee;
        if (_isReferee) {
            emit RefereeAdded(_referee);
        } else {
            emit RefereeUpdated(_referee);
        }
    }

    function setWinner(uint256 _id, address _winner) public onlyReferee {
        Tournament tournament = Tournament(tournaments[_id]);
        tournament.setWinner(_winner);
        emit WinnerSet(_id, _winner);
    }

    function requestRandomnessForPlayerPosition(uint256 _id) public onlyAdmin returns (uint256 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");

        requestId = vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
            })
        );
        requestIdToTournamentId[requestId] = _id;
        return requestId;
    }

    function fulfillRandomness(uint256 requestId, uint256 randomness) internal {
        uint256 tournamentId = getTournamentIdByRequestId(requestId);
        Tournament tournament = Tournament(tournaments[tournamentId]);

        require(tournament.randomnessRequestId() == requestId, "Invalid requestId");

        address[] memory playerss = tournament.players();
        require(playerss.length > 0, "No players to choose from");

        uint256 winnerIndex = randomness % playerss.length;
        address winner = playerss[winnerIndex];

        tournament.setWinner(winner);
        emit WinnerSet(tournamentId, winner);
    }

    function getTournamentIdByRequestId(uint256 requestId) internal view returns (uint256) {
       uint256 tournamentId = requestIdToTournamentId[requestId];
        require(tournamentId != 0, "Invalid requestId");
        return tournamentId;
    }

    receive() external payable {}
}
