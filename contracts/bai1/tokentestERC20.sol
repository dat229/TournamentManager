pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol"; 

contract TokentestERC20 is ERC20, ERC20Burnable, Ownable { 
  
    address payable private withdrawWallet;
    struct Whitelist{
        bool isBuyer;
        uint maxAmount; 
        uint boughtAmount; 
        uint price;
    }
    mapping(address => Whitelist) buyers;

    event buyToken(address buyer, uint tokenAmount, uint price);

    // E tạo token và phát hành 10 token khi khởi tạo.
     constructor(address stableTokenAddress) ERC20("GiangDat", "GD") Ownable(msg.sender) {
        require(stableTokenAddress != address(0), "Invalid address");
        withdrawWallet = payable(owner());
        
        _mint(msg.sender, 10 * 10**18);
    }

    function setWithdrawWallet(address payable _withdrawWallet) public onlyOwner{
        withdrawWallet = _withdrawWallet;
    }

    function setIsList(address lists, bool _isBuyer, uint _maxAmount, uint _price) public onlyOwner{
        buyers[lists].isBuyer = _isBuyer;
        buyers[lists].maxAmount = _maxAmount;
        buyers[lists].price = _price;
    }
    
    // Em mua bằng đồng amoy
    // Số lượng tiền max có thể mua.Nếu số lượng đã mua mà lớn hơn max thì không mua được.
    // Lấy ra giá tiền khi gửi lên sau đó sẽ chia cho số tiền đổi ra có thể mua được bao nhiêu token.
    function _buyToken() public {
        uint avaiableTokenAmount = buyers[msg.sender].maxAmount - buyers[msg.sender].boughtAmount;
        
        if(avaiableTokenAmount > 0){
            uint tokenAmount = msg.value/(buyers[msg.sender].price);
            
            require(buyers[msg.sender].isBuyer, "Ban khong co quyen mua");
            require(withdrawWallet.balanceOf(msg.sender) >= msg.value, "So du khong du de thuc hien giao dich nay");
            require(avaiableTokenAmount >= tokenAmount, "So luong token mua qua lon");
            
            buyers[msg.sender].boughtAmount += tokenAmount;
            withdrawWallet.transfer(msg.sender, tokenAmount);
            _mint(msg.sender, tokenAmount);
            
            emit buyToken(msg.sender, tokenAmount, buyers[msg.sender].price);
        }
    }

}