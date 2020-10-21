// SPDX-License-Identifier: CC-BY-NC-3.0

pragma solidity ^0.7.1;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import './token/ERC1363/ERC1363.sol';

contract inst is ERC1363, Ownable {
    using SafeMath for uint256;

    string private constant _name = 'Instant';
    string public _symbol = 'in.st';
    // A third of one billion tokens.
    uint256 public constant _totalSupply = 333333333333333;

    // represents if the address is denylisted with the contract. denylist takes priority before all other permissions
    mapping(address => bool) private _denylist;
    event AddedTodenylist(address[] addrs);
    event RemovedFromdenylist(address[] addrs);

    constructor() Ownable() ERC1363(_name,_symbol) {
        _setupDecimals(6);
        _mint(owner(), _totalSupply);
        emit Transfer(address(0x0), owner(), _totalSupply);
    }

    /**
     * @dev Enforce deny list before the funds are transfered.
     */
    function _beforeTokenTransfer(address from, address to, uint256 /*amount*/) view internal override {
      require(!_denylist[from], 'Instant has blocked sender');
      require(!_denylist[to], 'Instant has blocked receiver');
    }

    /**
     * @dev add addresses to denylist
     */
    function addToDenylist(address[] calldata addrs) external onlyOwner returns (bool) {
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
    function removeFromDenylist(address[] calldata addrs) external onlyOwner returns (bool) {
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
