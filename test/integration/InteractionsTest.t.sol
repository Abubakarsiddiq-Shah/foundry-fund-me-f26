//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; //These imports are built-in foundry contracts
import {FundMe} from "../../src/FundMe.sol"; //Importing the contract to be tested
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; //Importing the script to deploy the contract
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol"; //Importing the script to fund the contract

contract InteractionsTest is Test {
    address USER = makeAddr("user"); //Creating a variable of type address to hold the address of the user

    uint256 constant SEND_VALUE = 0.1 ether; //Setting the value to be sent in the fund function to 0.1 ETH

    uint256 constant STARTING_BALANCE = 10 ether; //Setting the starting balance of the USER address to 10 ETH

    uint256 constant GAS_PRICE = 1; //Setting the gas price to 1 gwei

    FundMe fundMe; //Creating a variable of type FundMe to hold the deployed contract

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();

        fundMe = deploy.run(); //Deploying the contract to be tested

        //   fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //Deploying the contract to be tested

        vm.deal(USER, STARTING_BALANCE); //Setting the balance of the USER address to 10 ETH
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe(); //Creating a new instance of the FundFundMe contract
        fundFundMe.fundFundMe(address(fundMe)); //Calling the fundFundMe function of the FundFundMe contract to fund the deployed contract

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); //Creating a new instance of the WithdrawFundMe contract
        withdrawFundMe.withdrawFundMe(address(fundMe)); //Calling the withdrawFundMe function

        assert(address(fundMe).balance == 0); //Asserting that the balance of the deployed contract is 0 after the withdrawal
    }
}
