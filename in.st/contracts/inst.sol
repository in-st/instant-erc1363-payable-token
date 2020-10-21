pragma solidity ^0.7.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'contracts/Ownable.sol';
import 'contracts/ERC1363/ERC1363.sol';

abstract contract inst is ERC223Token, Ownable {
    using SafeMath for uint256;

    string private override constant name = 'Instant';
    string public constant symbol = 'in.st';
    // A 3rd of 1 billion tokens.
    uint256 public override constant totalSupply = 333333333333333;
    uint8 private override decimals = 6;

    // represents if the address is denylisted with the contract. denylist takes priority before all other permissions
    mapping(address => bool) private _denylist;
    event AddedTodenylist(address[] addrs);
    event RemovedFromdenylist(address[] addrs);

    constructor() Ownable() ERC223Token() public{
        _setupDecimals(DECIMALS);
        _mint(owner(), totalSupply);
        emit Transfer(address(0x0), owner(), totalSupply);
    }

    /**
     * @dev Enforce deny list before the funds are transfered.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
      require(!_denylist[from], 'Instant has blocked sender');
      require(!_denylist[to], 'Instant has blocked receiver');
    }

    /**
     * @dev add addresses to denylist
     */
    function addTodenylist(address[] calldata addrs) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'instant: address should not be zero');
            _denylist[addr] = true;
        }

        emit AddedTodenylist(addrs);

        return true;
    }

    /**
     * @dev remove addresses from denylist
     */
    function removeFromdenylist(address[] calldata addrs) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'instant: address should not be zero');
            _denylist[addr] = false;
        }

        emit RemovedFromdenylist(addrs);

        return true;
    }
    /**
     * @dev Tokens must not be allowed to be destoryed, if one isn't needed any longer then the owner will take it back.
     */
    function burn(uint256 _amount) public {
      // tokens cannot be destroyed, they are returned.
      transfer(owner(), _amount);
    }

}
