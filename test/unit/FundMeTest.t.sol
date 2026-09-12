//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; //These imports are built-in foundry contracts
import {FundMe} from "../../src/FundMe.sol"; //Importing the contract to be tested
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; //Importing the script to deploy the contract

contract FundMeTest is Test {
    address USER = makeAddr("user"); //Creating a variable of type address to hold the address of the user

    uint256 constant SEND_VALUE = 0.1 ether; //Setting the value to be sent in the fund function to 0.1 ETH

    uint256 constant STARTING_BALANCE = 10 ether; //Setting the starting balance of the USER address to 10 ETH

    uint256 constant GAS_PRICE = 1; //Setting the gas price to 1 gwei

    FundMe fundMe; //Creating a variable of type FundMe to hold the deployed contract

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe(); //Creating a variable of type DeployFundMe to hold the deployed script
        fundMe = deployFundMe.run(); //Deploying the contract to be tested
        //   fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //Deploying the contract to be tested
        vm.deal(USER, STARTING_BALANCE); //Setting the balance of the USER address to 10 ETH
    } //Setup always run first before any test cases

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18); //Checking if the minimum USD is equal to 5e18
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender); //Checking if the owner of the contract is the same as the msg.sender
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion(); //Getting the version of the contract
        assertEq(version, 4); //Checking if the version of the contract is equal to 4
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert(); //Expecting the transaction to revert
        fundMe.fund(); //Calling the fund function without sending any ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //Setting the msg.sender to USER
        fundMe.fund{value: SEND_VALUE}(); //Calling the fund function with 10 ETH

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); //Getting the amount funded by the contract
        assertEq(amountFunded, SEND_VALUE); //Checking if the amount funded is equal to 10 ETH
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); //Setting the msg.sender to USER
        fundMe.fund{value: SEND_VALUE}(); //Calling the fund function with 10 ETH

        address funder = fundMe.getFunder(0); //Getting the first funder in the array of funders
        assertEq(funder, USER); //Checking if the first funder in the array of funders is equal to USER
    }

    modifier funded() {
        vm.prank(USER); //Setting the msg.sender to USER
        fundMe.fund{value: SEND_VALUE}(); //Calling the fund function with
        _; //Running the rest of the test case
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); //Setting the msg.sender to USER
        vm.expectRevert(); //Expecting the transaction to revert
        fundMe.withdraw(); //Calling the withdraw function
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //Getting the starting balance of the owner
        uint256 startingFundMeBalance = address(fundMe).balance; //Getting the starting balance of the contract

        //Act
        uint256 gasStart = gasleft(); //Getting the starting gas left
        vm.txGasPrice(GAS_PRICE); //Setting the gas price to 1 gwei
        vm.prank(fundMe.getOwner()); //Setting the msg.sender to the owner of the contract
        fundMe.withdraw(); //Calling the withdraw function
        uint256 gasEnd = gasleft(); //Getting the ending gas left
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //Calculating the gas used by multiplying the starting gas left minus the ending gas left by the transaction gas price
        console.log(gasUsed); //Logging the gas used

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; //Getting the ending balance of the owner
        uint256 endingFundMeBalance = address(fundMe).balance; //Getting the ending balance of the contract
        assertEq(endingFundMeBalance, 0); //Checking if the ending balance of the contract is equal to 0
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); //Checking if the starting balance of the contract plus the starting balance of the owner is equal to the ending balance of the owner
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10; //Setting the number of funders to 10
        uint160 startingFunderIndex = 1; //Setting the starting index of the funders to 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i), SEND_VALUE); //Setting the msg.sender to a new address and sending 10 ETH to that address
            fundMe.fund{value: SEND_VALUE}(); //Calling the fund function with 10 ETH
        }

        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //Getting the starting balance of the owner
        uint256 startingFundMeBalance = address(fundMe).balance; //Getting the starting balance of the contract

        vm.startPrank(fundMe.getOwner()); //Setting the msg.sender to the owner of the contract
        fundMe.withdraw(); //Calling the withdraw function
        vm.stopPrank(); //Stopping the prank

        //Assert
        assert(address(fundMe).balance == 0); //Checking if the balance of the contract is equal to 0
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); //Checking if the starting balance of the contract plus the starting balance of the owner is equal to the
        //ending balance of the owner
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10; //Setting the number of funders to 10
        uint160 startingFunderIndex = 1; //Setting the starting index of the funders to 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            //address()
            hoax(address(i), SEND_VALUE); //Setting the msg.sender to a new address and sending 10 ETH to that address
            fundMe.fund{value: SEND_VALUE}(); //Calling the fund function with 10 ETH
        }

        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //Getting the starting balance of the owner
        uint256 startingFundMeBalance = address(fundMe).balance; //Getting the starting balance of the contract

        vm.startPrank(fundMe.getOwner()); //Setting the msg.sender to the owner of the contract
        fundMe.cheaperWithdraw(); //Calling the cheaperWithdraw function
        vm.stopPrank(); //Stopping the prank

        //Assert
        assert(address(fundMe).balance == 0); //Checking if the balance of the contract is equal to 0
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); //Checking if the starting balance of the contract plus the starting balance of the owner is equal to the
        //ending balance of the owner
    }
}
