// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    function setUp() external {
        // Deploy the FundMe contract with the mock price feed address
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testDemo() public view {
        console.log("This is the amount: %s", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log("Price Feed Version: %s", version);
        assertEq(version, 4);
    }


    function testAmountFundedGreaterThanMinimumUSD() public {
       vm.expectRevert("You need to spend more ETH!");
       console.log("Funding with 8 wei...", block.chainid);
        fundMe.fund{value: 8}();
    }
}
