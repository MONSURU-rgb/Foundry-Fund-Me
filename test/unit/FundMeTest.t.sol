// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // Deploy the FundMe contract with the mock price feed address
        USER = makeAddr("ade");
        deployFundMe = new DeployFundMe();
        // vm.prank(USER);
        fundMe = deployFundMe.run();
    }

    function testDemo() public view {
        console.log("This is the amount: %s", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testAmountFundedGreaterThanMinimumUSD() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund{value: 8}();
    }

    modifier fund() {
        vm.deal((USER), 0.2 ether);
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        _;
    }

    function testOnlyOwnerCanWithdraw() public fund {
        address deployer = fundMe.getOwner(); // Assuming getOwner() returns correct address
        vm.deal(deployer, 1 ether);
        vm.prank(deployer); // prank the next call as deployer (the owner)

        fundMe.fund{value: 0.1 ether}();

        uint256 startingBalance = deployer.balance;

        vm.prank(deployer); // ensure withdraw is called by the owner
        fundMe.withdraw();

        uint256 endingBalance = deployer.balance;

        assertEq(fundMe.getOwner(), deployer);
        assertGt(endingBalance, startingBalance);

        // address deployer = fundMe.getOwner();
        // vm.deal(deployer, 1 ether);
        // vm.prank(deployer);
        // fundMe.fund{value: 0.1 ether}();

        // uint256 startingBalance = address(this).balance;
        // fundMe.withdraw();

        // uint256 endingBalance = address(this).balance;
        //
        // assertGt(endingBalance, startingBalance);
    }

    function testWithdrawWithAsingleFounder() public fund {
        // Arrange
        vm.deal((USER), 0.2 ether);
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log("starting point", startingOwnerBalance, startingFundMeBalance);

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testIfMultipleFunderAmount() public fund {
        uint160 numberIndex = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberIndex; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;
        console.log("gas used", gasEnd, gasStart, gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testIfMultipleFunderAmountCheaper() public fund {
        uint160 numberIndex = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberIndex; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdrawal();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;
        console.log("gas used", gasEnd, gasStart, gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }
}
