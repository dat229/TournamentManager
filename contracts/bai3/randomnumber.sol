pragma solidity >=0.8.2 <0.9.0;

import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Vrf{
    bytes32 public keyHash; 
    uint256 public s_subscriptionId;
    IVRFCoordinatorV2Plus internal vrfCoordinator;
    uint16 internal requestConfirmations = 3;
    uint32 internal callbackGasLimit = 250000;
    uint32 internal numWords = 1;

    function getRequestRandomnessForPlayerPosition(bytes32 _keyHash,IVRFCoordinatorV2Plus vrfCoordinator,uint256 _s_subscriptionId) public returns (uint256 requestId) {
        requestId = vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: _keyHash,
                subId: _s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
            })
        );
        return requestId;
    }

    constructor(address _VRFCoordinator, bytes32 _keyHash, uint256 _s_subscriptionId){
        vrfCoordinator = IVRFCoordinatorV2Plus(_VRFCoordinator);
        keyHash = _keyHash;
        s_subscriptionId = _s_subscriptionId;
    }


} 