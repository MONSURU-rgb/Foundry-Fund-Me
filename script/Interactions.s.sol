// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.001 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        // vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        // vm.stopBroadcast();
    }

    function run() public {
        vm.startBroadcast();
        address MostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(MostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(mostRecentlyDeployed);
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        // console.log("Withdraw Fund Me with %s", SEND_VALUE);
    }

    function run() public {
        vm.startBroadcast();
        address MostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(MostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
