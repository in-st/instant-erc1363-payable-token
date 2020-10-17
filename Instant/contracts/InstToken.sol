pragma solidity 0.6.2;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';


abstract contract IERC223Recipient {
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes memory _data) virtual public;
}


/**
 * @title InstToken
 * @dev Simple ERC20 Token with freezing and allowlist feature.
 */

contract InstToken is ERC20, Ownable {
    using SafeMath for uint256;

    // modify token name
    string public constant NAME = 'Instant';
    // modify token symbol
    string public constant SYMBOL = 'in.st';
    // modify token decimals
    uint8 public constant DECIMALS = 6;
    // modify initial token supply
    uint256 public constant INITIAL_SUPPLY = 300000000 * (10**uint256(DECIMALS)); // 300,000,000 tokens

    // indicate if the token is freezed or not
    bool public freezed;

    mapping (address => uint256) private _balances;

    struct allowlistInfo {
        // if account has allow deposit permission then it should be possible to deposit tokens to that account
        // as long as accounts depositing have allow_transfer permission
        bool allow_deposit;
        // if account has allow transfer permission then that account should be able to transfer tokens to other
        // accounts with allow_deposit permission
        bool allow_transfer;
        // deposit to the account should be possible even if account depositing has no permission to transfer
        bool allow_unconditional_deposit;
        // transfer from the account should be possible to any account even if the destination account has no
        // deposit permission
        bool allow_unconditional_transfer;
    }

    // represents if the address is denylisted with the contract. denylist takes priority before all other permissions like allowlist
    mapping(address => bool) private _denylist;

    // represents if the address is allowed or not
    mapping(address => allowlistInfo) private _allowlist;

    // Events
    event allowlistConfigured(
        address[] addrs,
        bool allow_deposit,
        bool allow_transfer,
        bool allow_unconditional_deposit,
        bool allow_unconditional_transfer
    );
    event AddedTodenylist(address[] addrs);
    event RemovedFromdenylist(address[] addrs);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() public Ownable() ERC20(NAME, SYMBOL) {
        _setupDecimals(DECIMALS);
        _mint(msg.sender, INITIAL_SUPPLY);
        emit Transfer(address(0x0), msg.sender, INITIAL_SUPPLY);
        freezed = true;

        // owner's allowlist
        _allowlist[msg.sender].allow_deposit = true;
        _allowlist[msg.sender].allow_transfer = true;
        _allowlist[msg.sender].allow_unconditional_deposit = true;
        _allowlist[msg.sender].allow_unconditional_transfer = true;
    }

    /**
     * @dev freeze and unfreeze functions
     */
    function freeze() external onlyOwner {
        require(freezed == false, 'in.st: already freezed');
        freezed = true;
    }

    function unfreeze() external onlyOwner {
        require(freezed == true, 'in.st: already unfreezed');
        freezed = false;
    }

    /**
     * @dev configure allowlist to an address
     * @param addrs the addresses to be allowed
     * @param allow_deposit boolean variable to indicate if deposit is allowed
     * @param allow_transfer boolean variable to indicate if transfer is allowed
     * @param allow_unconditional_deposit boolean variable to indicate if unconditional deposit is allowed
     * @param allow_unconditional_transfer boolean variable to indicate if unconditional transfer is allowed
     */
    function allowlist(
        address[] calldata addrs,
        bool allow_deposit,
        bool allow_transfer,
        bool allow_unconditional_deposit,
        bool allow_unconditional_transfer
    ) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'in.st: address should not be zero');

            _allowlist[addr].allow_deposit = allow_deposit;
            _allowlist[addr].allow_transfer = allow_transfer;
            _allowlist[addr].allow_unconditional_deposit = allow_unconditional_deposit;
            _allowlist[addr].allow_unconditional_transfer = allow_unconditional_transfer;
        }

        emit allowlistConfigured(addrs, allow_deposit, allow_transfer, allow_unconditional_deposit, allow_unconditional_transfer);

        return true;
    }

    /**
     * @dev add addresses to denylist
     */
    function addTodenylist(address[] calldata addrs) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'in.st: address should not be zero');

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
            require(addr != address(0), 'in.st: address should not be zero');

            _denylist[addr] = false;
        }

        emit RemovedFromdenylist(addrs);

        return true;
    }

    function multiTransfer(address[] calldata addrs, uint256 amount) external returns (bool) {
        require(amount > 0, 'in.st: amount should not be zero');
        require(balanceOf(msg.sender) >= amount.mul(addrs.length), 'in.st: amount should be less than the balance of the sender');

        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != msg.sender, 'in.st: address should not be sender');
            require(addr != address(0), 'in.st: address should not be zero');

            transfer(addr, amount);
        }

        return true;
    }

    /**
     * @dev Returns if the address is on the allowlist or not.
     */
    function allowlist(address addr)
        public
        view
        returns (
            bool,
            bool,
            bool,
            bool
        )
    {
        return (
            _allowlist[addr].allow_deposit,
            _allowlist[addr].allow_transfer,
            _allowlist[addr].allow_unconditional_deposit,
            _allowlist[addr].allow_unconditional_transfer
        );
    }

    /**
     * @dev Returns if the address is on the denylist or not.
     */
    function denylisted(address addr) public view returns (bool) {
        return _denylist[addr];
    }

    /**
     * @dev Hook before transfer
     * check from and to are allowed when the token is freezed
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(to != address(0));
        require(amount <= _balances[from]);
        super._beforeTokenTransfer(from, to, amount);
        require(!_denylist[from], 'in.st: sender is denylisted.');
        require(!_denylist[to], 'in.st: receiver is denylisted.');
        require(
            !freezed ||
                _allowlist[from].allow_unconditional_transfer ||
                _allowlist[to].allow_unconditional_deposit ||
                (_allowlist[from].allow_transfer && _allowlist[to].allow_deposit),
            'in.st: token transfer while freezed and not allowed.'
        );
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
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        if(Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
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
        bytes memory empty = hex"00000000";
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        if(Address.isContract(_to)) {
            IERC223Recipient receiver = IERC223Recipient(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
        return true;
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
