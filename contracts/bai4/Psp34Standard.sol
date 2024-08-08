// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Psp34standard is ERC721, Ownable {
    uint64 public lastTokenId;

    error PickupError(string message);

    // Thiết lập tên và ký hiệu
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    //Mint nft, mỗi lần mint e sẽ set lastTokenId + 1 để không trùng, sau đó e set tokenid = lastTokenId để tokenid là duy nhất.
    function mint(address to, uint256 tokenId) public onlyOwner {
        lastTokenId += 1;
        tokenId = lastTokenId;

        _mint(to, tokenId);
    }
   
    // Lấy URI từ token ID 
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURI(tokenId);
    }

    // Hủy token
    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
