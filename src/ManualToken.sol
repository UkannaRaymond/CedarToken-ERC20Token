// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract ManualToken {
    mapping(address => uint256) s_balanceOfOwner;

    function name() public pure returns (string memory) {
        return "Manuel Token";
    }

    function symbol() public pure returns (string memory) {
        return "MT";
    }

    function decimal() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 1000 ether;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balanceOfOwner[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        uint256 previouBalance = balanceOf(msg.sender) + balanceOf(_to);
        s_balanceOfOwner[msg.sender] -= _amount;
        s_balanceOfOwner[_to] += _amount;
        require(balanceOf(msg.sender) + balanceOf(_to) == previouBalance);
    }
}
