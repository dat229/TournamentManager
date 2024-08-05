pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 

contract USDT is ERC20{
    constructor() ERC20("USDT", "USDT"){
        _mint(msg.sender, 1000);
    }
    function mint(uint amount) public{
        _mint(msg.sender, amount);
    }
}