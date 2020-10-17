pragma solidity 0.6.2;
import 'contracts/InstToken.sol';

abstract contract inGold is InstToken {
    using SafeMath for uint256;

    // modify token name
    string public constant NAME = 'Instant Gold';
    // modify token symbol
    string public constant SYMBOL = 'in.Gold';
    // modify token decimals
    uint8 public constant DECIMALS = 6;
    // modify initial token supply
    uint256 public constant INITIAL_SUPPLY = 300000000 * (10**uint256(DECIMALS)); // 300,000,000 tokens
}
