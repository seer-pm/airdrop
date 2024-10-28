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
    uint256 amount = 0.02 ether;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        GovernedRecipient governedRecipient = GovernedRecipient(vm.envAddress("GOVERNED_RECIPIENT_ADDRESS"));

        vm.startBroadcast(deployerPrivateKey);

        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/recipients.json");
        string memory json = vm.readFile(path);
        address[] memory recipients = abi.decode(vm.parseJson(json), (address[]));

        uint256[] memory amounts = new uint256[](recipients.length);
        for(uint256 i = 0; i < recipients.length; i++) {
            amounts[i] = amount;
        }
        Disperse(disperse).disperseEther{value: amount * recipients.length}(recipients, amounts);

        governedRecipient.addRecipients(recipients);

        vm.stopBroadcast();

        console.log("Added recipients:", recipients.length);
    }
}
