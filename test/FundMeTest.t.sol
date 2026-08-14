//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; //These imports are built-in foundry contracts
import {FundMe} from "../src/FundMe.sol"; //Importing the contract to be tested

contract FundMeTest is Test{

    FundMe fundMe; //Creating a variable of type FundMe to hold the deployed contract

     function setUp() external{
        fundMe = new FundMe(); //Deploying the contract to be tested
     } //Setup always run first before any test cases

      function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18); //Checking if the minimum USD is equal to 5e18
      }

   function testOwnerIsMsgSender() public{
        assertEq(fundMe.i_owner(), address(this)); //Checking if the owner of the contract is the same as the msg.sender
   }

   function testPriceversionIsAccurate() public{
      uint256 version = fundMe.getVersion(); //Getting the version of the contract
      assertEq(fundMe.version(), 4); //Checking if the version of the contract is equal to 4
   }
}