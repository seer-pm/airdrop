// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/GovernedRecipient.sol";
import "../src/MultiDrop.sol";
import "forge-std/Script.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        GovernedRecipient governedRecipient = new GovernedRecipient();
        MultiDrop multiDrop = new MultiDrop(governedRecipient);

        vm.stopBroadcast();

        console.log("GovernedRecipient deployed to:", address(governedRecipient));
        console.log("MultiDrop deployed to:", address(multiDrop));
    }
}
