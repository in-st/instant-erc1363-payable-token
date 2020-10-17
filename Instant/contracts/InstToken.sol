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
 * @dev Simple ERC20 Token with freezing and whitelist feature.
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

    struct WhitelistInfo {
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

    // represents if the address is blacklisted with the contract. Blacklist takes priority before all other permissions like whitelist
    mapping(address => bool) private _blacklist;

    // represents if the address is whitelisted or not
    mapping(address => WhitelistInfo) private _whitelist;

    // Events
    event WhitelistConfigured(
        address[] addrs,
        bool allow_deposit,
        bool allow_transfer,
        bool allow_unconditional_deposit,
        bool allow_unconditional_transfer
    );
    event AddedToBlacklist(address[] addrs);
    event RemovedFromBlacklist(address[] addrs);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() public Ownable() ERC20(NAME, SYMBOL) {
        _setupDecimals(DECIMALS);
        _mint(msg.sender, INITIAL_SUPPLY);
        emit Transfer(address(0x0), msg.sender, INITIAL_SUPPLY);
        freezed = true;

        // owner's whitelist
        _whitelist[msg.sender].allow_deposit = true;
        _whitelist[msg.sender].allow_transfer = true;
        _whitelist[msg.sender].allow_unconditional_deposit = true;
        _whitelist[msg.sender].allow_unconditional_transfer = true;
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
     * @dev configure whitelist to an address
     * @param addrs the addresses to be whitelisted
     * @param allow_deposit boolean variable to indicate if deposit is allowed
     * @param allow_transfer boolean variable to indicate if transfer is allowed
     * @param allow_unconditional_deposit boolean variable to indicate if unconditional deposit is allowed
     * @param allow_unconditional_transfer boolean variable to indicate if unconditional transfer is allowed
     */
    function whitelist(
        address[] calldata addrs,
        bool allow_deposit,
        bool allow_transfer,
        bool allow_unconditional_deposit,
        bool allow_unconditional_transfer
    ) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'in.st: address should not be zero');

            _whitelist[addr].allow_deposit = allow_deposit;
            _whitelist[addr].allow_transfer = allow_transfer;
            _whitelist[addr].allow_unconditional_deposit = allow_unconditional_deposit;
            _whitelist[addr].allow_unconditional_transfer = allow_unconditional_transfer;
        }

        emit WhitelistConfigured(addrs, allow_deposit, allow_transfer, allow_unconditional_deposit, allow_unconditional_transfer);

        return true;
    }

    /**
     * @dev add addresses to blacklist
     */
    function addToBlacklist(address[] calldata addrs) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'in.st: address should not be zero');

            _blacklist[addr] = true;
        }

        emit AddedToBlacklist(addrs);

        return true;
    }

    /**
     * @dev remove addresses from blacklist
     */
    function removeFromBlacklist(address[] calldata addrs) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < addrs.length; i++) {
            address addr = addrs[i];
            require(addr != address(0), 'in.st: address should not be zero');

            _blacklist[addr] = false;
        }

        emit RemovedFromBlacklist(addrs);

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
     * @dev Returns if the address is whitelisted or not.
     */
    function whitelisted(address addr)
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
            _whitelist[addr].allow_deposit,
            _whitelist[addr].allow_transfer,
            _whitelist[addr].allow_unconditional_deposit,
            _whitelist[addr].allow_unconditional_transfer
        );
    }

    /**
     * @dev Returns if the address is on the blacklist or not.
     */
    function blacklisted(address addr) public view returns (bool) {
        return _blacklist[addr];
    }

    /**
     * @dev Hook before transfer
     * check from and to are whitelisted when the token is freezed
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!_blacklist[from], 'in.st: sender is blacklisted.');
        require(!_blacklist[to], 'in.st: receiver is blacklisted.');
        require(
            !freezed ||
                _whitelist[from].allow_unconditional_transfer ||
                _whitelist[to].allow_unconditional_deposit ||
                (_whitelist[from].allow_transfer && _whitelist[to].allow_deposit),
            'in.st: token transfer while freezed and not whitelisted.'
        );
    }

    // ERC223 Support
    event Transfer(address indexed _from, address indexed _to, uint _value, bytes _data);

    function dex() public view returns(address)
    {
        return owner();
    }

    function dexMint(uint _amount)
        public
        onlyOwner()
    {
        _mint(dex(), _amount);
    }

    function dexBurn(uint _amount)
        public
        onlyOwner()
    {
        _burn(dex(), _amount);
    }

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
    function transfer(address _to, uint _value) public override returns (bool success) {
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

    // function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool success) {
        _burn(msg.sender, _value);
        _mint(_to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }


}
