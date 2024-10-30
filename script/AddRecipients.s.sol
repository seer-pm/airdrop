// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/GovernedRecipient.sol";
import "../src/MultiDrop.sol";
import "forge-std/Script.sol";

interface Disperse {
    function disperseEther(address[] memory recipients, uint256[] memory values) external payable;
}

contract AddRecipients is Script {
    address disperse = address(0xD152f549545093347A162Dce210e7293f1452150); // gnosis chain address
    uint256 amount = 0.05 ether;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        GovernedRecipient governedRecipient = GovernedRecipient(vm.envAddress("GOVERNED_RECIPIENT_ADDRESS"));

        vm.startBroadcast(deployerPrivateKey);

        address[] memory recipients = vm.envAddress("RECIPIENTS_ADDRESSES", ",");
        uint256[] memory amounts = new uint256[](recipients.length);
        uint256 disperseAmount = 0;

        for(uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i].balance < amount) {
                amounts[i] = amount;
                disperseAmount += amount;
            }
        }

        if (disperseAmount > 0) {
            Disperse(disperse).disperseEther{value: disperseAmount}(recipients, amounts);
        }

        governedRecipient.addRecipients(recipients);

        vm.stopBroadcast();

        console.log("Added recipients:", recipients.length);
    }
}
