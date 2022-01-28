//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface CCurve{
    function mint(uint amount, address to) external;
}

contract CToken is ERC20 {
    CCurve immutable ccurve;

    constructor(uint256 initialSupply, CCurve _ccurve) ERC20("Tuba Edition 0", "TUBA") {
        _mint(msg.sender, initialSupply);
        ccurve = _ccurve;
    }

    function burn(uint amount) external {
        require(amount % 1e18 == 0, "Can only burn whole tokens");
        _burn(msg.sender, amount);
        ccurve.mint(amount/1e18, msg.sender);
    }
}
