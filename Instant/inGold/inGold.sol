pragma solidity 0.6.2;
import 'contracts/InstToken.sol';

abstract contract inGold is InstToken {
    using SafeMath for uint256;

    string public constant NAME = 'Instant Gold';
    string public constant SYMBOL = 'in.Gold';
    uint8 public constant DECIMALS = 6;

    // A 3rd of 1 billion tokens.
    uint32 private constant _totalSupply = 333333333;
}
