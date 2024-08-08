pragma solidity ^0.8.0;


contract UserManager {
    struct User {
        string name;
        string ipfsHash; // Mục đích để e gán với lưu trữ dữ liệu liên quan đến người dùng trên IPFS
    }

    mapping(address => User) private users;
    address[] private userAddresses;

    event UserRegistered(address indexed userAddress, string name, string ipfsHash);
    event UserUpdated(address indexed userAddress, string name, string ipfsHash);

    // Đăng ký 1 người dùng mới
    function registerUser(string memory name, string memory ipfsHash) public {
        require(bytes(users[msg.sender].name).length == 0, "User already registered");

        users[msg.sender] = User(name, ipfsHash);
        userAddresses.push(msg.sender);

        emit UserRegistered(msg.sender, name, ipfsHash);
    }

    // lấy ra toàn bộ người dùng
    function getAllUsers() public view returns (User[] memory) {
        User[] memory allUsers = new User[](userAddresses.length);
        for (uint i = 0; i < userAddresses.length; i++) {
            allUsers[i] = users[userAddresses[i]];
        }
        return allUsers;
    }
}