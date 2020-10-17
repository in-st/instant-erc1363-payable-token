pragma solidity 0.6.2;
import 'contracts/InstToken.sol';

abstract contract instcoin is InstToken {
    using SafeMath for uint256;

    string public constant NAME = 'Instant';
    string public constant SYMBOL = 'in.st';
    uint8 public constant DECIMALS = 6;

    // A 3rd of 1 billion tokens.
    uint256 public override constant totalSupply = 333333333;
}
