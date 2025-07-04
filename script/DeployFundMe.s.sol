//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "forge-std/Test.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        HelperConfig helperConfig = new HelperConfig();

        // You can also use the HelperConfig to get the price feed address dynamically

        vm.startBroadcast();
        // Deploy the FundMe contract with the pric;e feed address
       address priceFeed = helperConfig.activeNetworkConfig();
        console.log("Deploying FundMe with price feed: %s", priceFeed);

        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
