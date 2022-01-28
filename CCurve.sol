//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Ownable.sol";

contract CCurve is ERC1155, Ownable {
    address public multisig;
    uint public issuedTokens = 1;
    mapping(address=>uint) public tokenToId;

    constructor() ERC1155("https://combatcurve.com/uri/{id}.json") {
        multisig = msg.sender;
    }

    function mint(uint amount, address to) external {
        uint id = tokenToId[msg.sender];
        require(id != 0, "id != 0");
        _mint(to, id, amount, "");
    }

    modifier onlyMultisig() {
        require(multisig == msg.sender, "!multisig");
        _;
    }

    function transferMultisig(address newMultisig) external onlyMultisig {
        multisig = newMultisig;
    }

    function setOwner(address newOwner) external onlyMultisig {
        _setOwner(newOwner);
    }

    function setUri(string memory newUri) external onlyMultisig {
        _setURI(newUri);
    }

    function addToken(address newToken) external onlyMultisig {
        require(tokenToId[newToken] == 0, "no rugging");
        tokenToId[newToken] = issuedTokens;
        unchecked {
            issuedTokens += 1;
        }
    }
    
    function contractURI() public view returns (string memory) {
        return "https://combatcurve.com/uri/_contracturi.json";
    }
}
