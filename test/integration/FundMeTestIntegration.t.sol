// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundMeIntegrationTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(address(fundMe), STARTING_BALANCE);
    }

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
           fundMe.fund{value: STARTING_BALANCE}();
        vm.prank(USER);
        vm.deal((USER), 10e18);
        fundFundMe.fundFundMe(address(fundMe));
        address funder = fundMe.getFunders(0);
        console.log("Owner is", fundMe.getOwner(), funder);

        console.log("funder is", funder, address(fundMe), address(fundFundMe));
        assertEq(funder, USER);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        vm.prank(fundMe.getOwner());

        withdrawFundMe.withdrawFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}
