// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./TRC20.sol";
import "./BlackList.sol";

contract UpgradedTRC20Token is TRC20 {
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    uint public _totalSupply;
    function transferByLegacy(address from, address to, uint value) public returns (bool);
    function transferFromByLegacy(address sender, address from, address spender, uint value) public returns (bool);
    function approveByLegacy(address from, address spender, uint value) public returns (bool);
    function increaseAllowanceByLegacy(address from, address spender, uint addedValue) public returns (bool);
    function decreaseAllowanceByLegacy(address from, address spender, uint subtractedValue) public returns (bool);
}

/**
 * @title SimpleToken
 * @dev Very simple TRC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `TRC20` functions.
 */
contract Token is TRC20, BlackList {
    address public upgradedAddress;
    bool public deprecated;
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public TRC20Detailed("Farda", "FDA", 6) {
        deprecated = false;
        _mint(msg.sender, 10000000 * (10 ** uint256(decimals())));
    }

        // Forward ERC20 methods to upgraded contract if this one is deprecated
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
        require(!isBlackListed[msg.sender], "TRC20: You have been banned on this contract");
        if (deprecated) {
            return UpgradedTRC20Token(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {
        require(!isBlackListed[_from], "TRC20: This user have been banned on this contract");
        if (deprecated) {
            return UpgradedTRC20Token(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
        } else {
            return super.transferFrom(_from, _to, _value);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function balanceOf(address who) public view returns (uint) {
        if (deprecated) {
            return UpgradedTRC20Token(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    // Allow checks of balance at time of deprecation
    function oldBalanceOf(address who) public view returns (uint) {
        if (deprecated) {
            return super.balanceOf(who);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function approve(address _spender, uint _value) public whenNotPaused returns (bool) {
        if (deprecated) {
            return UpgradedTRC20Token(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            return super.approve(_spender, _value);
        }
    }

    function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
        if (deprecated) {
            return UpgradedTRC20Token(upgradedAddress).increaseAllowanceByLegacy(msg.sender, _spender, _addedValue);
        } else {
            return super.increaseAllowance(_spender, _addedValue);
        }
    }

    function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
        if (deprecated) {
            return UpgradedTRC20Token(upgradedAddress).decreaseAllowanceByLegacy(msg.sender, _spender, _subtractedValue);
        } else {
            return super.decreaseAllowance(_spender, _subtractedValue);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        if (deprecated) {
            return TRC20(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }

    // deprecate current contract in favour of a new one
    function deprecate(address _upgradedAddress) public onlyOwner {
        require(_upgradedAddress != address(0));
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }

    // deprecate current contract if favour of a new one
    function totalSupply() public view returns (uint) {
        if (deprecated) {
            return TRC20(upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }

    // Called when contract is deprecated
    event Deprecate(address newAddress);
}
