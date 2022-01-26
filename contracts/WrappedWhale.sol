pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract WrappedWhale is  ERC20Pausable, ReentrancyGuard, Ownable {

    IERC20 WhaleToken;

    constructor(address _whaleToken) ERC20("Wrapped WhaleFall", "WWHALE") {
        WhaleToken = IERC20(_whaleToken);
    }

    bool public mintPaused;
    bool public burnPaused;
    mapping(address => bool) public mintBlackList;
    mapping(address => bool) public burnBlackList;

    function mint(address _to, uint _amount) public nonReentrant returns(bool){
        require(!mintPaused, "Mint Unpaused");
        require(!mintBlackList[msg.sender], "Mint Blacklist");
        WhaleToken.transferFrom(msg.sender, address(this), _amount);
        _mint(_to, _amount);
        return true;
    }

    function burn(uint _amount) public nonReentrant returns(bool){
        require(!burnPaused, "Burn Unpaused");
        require(!burnBlackList[msg.sender], "Burn Blacklist");
        _burn(msg.sender, _amount);
        WhaleToken.transfer(msg.sender, _amount);
        return true;
    }

    function setBurnPaused() public onlyOwner {
        burnPaused = !burnPaused;
    }

    function setMintPaused() public onlyOwner {
        mintPaused = !mintPaused;
    }

    function setMintBlacklist(address[] memory  _addresses, bool[] memory _bools) public onlyOwner {
        require(_addresses.length == _bools.length);
        for (uint256 index = 0; index < _addresses.length; index++) {
            mintBlackList[_addresses[index]] = _bools[index];
        }
    }

    function setBurnBlacklist(address[] memory  _addresses, bool[] memory _bools) public onlyOwner {
        require(_addresses.length == _bools.length);
        for (uint256 index = 0; index < _addresses.length; index++) {
            burnBlackList[_addresses[index]] = _bools[index];
        }
    }

}