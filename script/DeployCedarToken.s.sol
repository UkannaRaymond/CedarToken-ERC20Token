// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Script} from "forge-std/Script.sol";
import {CedarToken} from "src/CedarToken.sol";

contract DeployCedarToken is Script {
    uint256 public INITIAL_SUPPLY = 1000 ether;

    function run() external returns (CedarToken) {
        vm.startBroadcast();
        CedarToken cedarToken = new CedarToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return cedarToken;
    }
}
