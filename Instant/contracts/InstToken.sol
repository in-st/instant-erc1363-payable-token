pragma solidity 0.6.2;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'contracts/IERC223Recipient.sol';

/**
 * @title InstToken
 * @dev Simple ERC20 Token with freezing and blacklist
 */

abstract contract InstToken is ERC20, Ownable {
    uint32 private _totalSupply;
    mapping (address => uint256) private _balances;
    // represents if the address is denylisted with the contract. denylist takes priority before all other permissions
    mapping(address => bool) private _denylist;
    event AddedTodenylist(address[] addrs);
    event RemovedFromdenylist(address[] addrs);

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
    event Transfer(address indexed _from, address indexed _to, uint _value, bytes _data);

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success){
        // Make sure this transfer is allowed.
        require(_to != address(0) && _to != address(this));
        require(!_denylist[msg.sender], 'instant: sender blocked');
        require(!_denylist[_to], 'instant: receiver blocked');
        // Standard function transfer similar to ERC20 transfer with no _data.
        // Added due to backwards compatibility reasons .
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        if(Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        // Complete the transaction.
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function transferAndCall(address _to, uint _value, bytes memory _data)
      public
      returns (bool success)
    {
      return transfer(_to, _value, _data);
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public override(ERC20) returns (bool success) {
        bytes memory empty = hex"";
        return transfer(_to, _value, empty);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }
}
