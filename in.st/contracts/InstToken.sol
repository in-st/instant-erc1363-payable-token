pragma solidity 0.6.2;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'contracts/IERC223Recipient.sol';

/**
 * @title InstToken
 * @dev Simple ERC20 Token with freezing and blacklist
 */

contract inst is ERC20, Ownable {
    using SafeMath for uint256;

    string private override constant _name = 'Instant';
    string public constant _symbol = 'in.st';
    // A 3rd of 1 billion tokens.
    uint256 public constant _totalSupply = 333333333333333;

    //mapping (address => uint256) public _balances;
    // represents if the address is denylisted with the contract. denylist takes priority before all other permissions
    mapping(address => bool) private _denylist;
    event AddedTodenylist(address[] addrs);
    event RemovedFromdenylist(address[] addrs);

    constructor() public Ownable() ERC20(_name, _symbol){
        _setupDecimals(6);
        _mint(owner(), _totalSupply);
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

    // ERC223 Support
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param recipient    recipient address.
     * @param amount Amount of tokens that will be transferred.
     * @param memo  Transaction metadata.
     */
    /*function transfer(address recipient, uint amount, bytes memory memo) public returns (bool success){
        // Make sure this transfer is allowed.
        require(recipient != address(0) && recipient != address(this));
        require(!_denylist[msg.sender], 'instant: sender blocked');
        require(!_denylist[recipient], 'instant: recipient blocked');
        // Standard function transfer similar to ERC20 transfer with no memo.
        // Added due to backwards compatibility reasons .
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        // Complete the transaction.
        emit Transfer(msg.sender, recipient, amount, memo);
        return true;
    }*/

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     * 
     * @param to   address where they will be transferred.
     * @param amount  Transaction metadata.
     */
    function _beforeTokenTransfer(address /*from*/, address to, uint256 amount) internal override {
      // this message type is not needed for our token,
      // always empty.
      bytes memory empty = hex"";
      if(Address.isContract(to)) {
          IERC223Recipient receiver = IERC223Recipient(to);
          receiver.tokenFallback(msg.sender, amount, empty);
      }
    }

/*
    function transferAndCall(address recipient, uint amount, bytes memory memo) public returns (bool success)
    {
      return transfer(recipient, amount, memo);
    }*/

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }
    //Events
    event TotalSupply(uint256 totalSupply);
    event BalanceOf(address addr, uint256 balance);
    event Burn(address indexed receiver, uint256 amount);
    event Transfer(address indexed sender, address indexed receiver, uint256 amount, bytes data);
    event GetOwner(address indexed owner);
    event Mint(address indexed receiver, uint256 amount);
}
