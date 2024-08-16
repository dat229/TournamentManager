pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract NodeManager is Ownable(msg.sender){
    struct NodeInformation {
        bool status;
        string name;
        string metadata;
    }

    struct DiscountCoupon {
        bool status;
        uint32 disount_percent;
    }

    mapping (address location => NodeInformation nodeInformation) public node;
    mapping (bytes32 code => DiscountCoupon discountCoupon) public discount;

    function getNodeInformation(address _location) public view returns(NodeInformation memory nodeInformation) {
        require(_location!=address(0),"address is null");
        require(node[_location].status,"Node is null");
        return node[_location];
    }

    function createNodeInformation(address _location, string memory _name, string memory _metadata) public onlyOwner {
        require(_location!=address(0) && node[_location].status,"address is null");
        require(bytes(_name).length != 0,"name is null");
        require(bytes(_metadata).length != 0,"metadata is null");

        node[_location] = NodeInformation(true,_name,_metadata);

        node[_location].name = _name;
        node[_location].metadata = _metadata;
    }

    function setNodeInformation(address _location, string memory _name, string memory _metadata) public onlyOwner {
        require(_location!=address(0) && node[_location].status,"address is null");
        require(bytes(_name).length != 0,"name is null");
        require(bytes(_metadata).length != 0,"metadata is null");

        node[_location].name = _name;
        node[_location].metadata = _metadata;
    }

    function deleteNodeInformation(address _location) public {
        delete node[_location];
    }

    function setDiscountCoupon(string memory _code, uint32 _disount_percent) public onlyOwner {
        bytes32 code = keccak256(abi.encodePacked(_code));
        require(code.length>0,"address is null");
        require(_disount_percent > 0,"Disount percent is greate than 0");

        discount[code].disount_percent = _disount_percent;
    }

    function deleteDiscountCoupon(string memory _code) public {
        bytes32 code = keccak256(abi.encodePacked(_code));
        delete discount[code];
    }

}