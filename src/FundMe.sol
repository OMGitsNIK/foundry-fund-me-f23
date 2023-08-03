// get funds from users
// withdraw the funds
// set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner(); // custom error

contract FundMe {
    // constant : variables are initialised outside any function and on the same line they are declared
    // immutable : variables are initialised inside any function and on a different line they were declared
    // the above save gas, because they store variables directly in the bytecode of the contract, and not in the storage

    using PriceConverter for uint256;

    address private immutable i_owner; //owner address to make sure only owner can withdraw
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    //uint256 myValue = 1;
    //uint256 public minimumUsd = 5 * 1e18 ; // minimum of $5 needed // changed for gas optimization
    uint256 public constant MINIMUM_USD = 5 * 1e18;
    address[] private s_funders;
    mapping(address s_funders => uint256 amountFunded)
        private s_addressToAmountFunded;

    // to send money to our contract
    function fund() public payable {
        //myValue = myValue + 2;

        //require(msg.value >= 1e18, "Didnt send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000 wei = 1*10^18
        // revert = undo any actions done and return the remaining gas back
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didnt send enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }


    function cheaperWithdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for(uint256 funderIndex = 0; funderIndex < funderLength; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    // to withdraw the funds
    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Must be owner to withdraw"); // not needed since we are using modifiers

        for (
            uint256 funderIndex = 0;
            funderIndex > s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // to reset the funders array
        s_funders = new address[](0);

        // to actually withdraw funds there are 3 ways
        //1) transfer (if failed, throws an error)
        //2) send (if failed, returns bool)
        //3) call

        // msg.sender = adddress
        // payable(msg.sender) = payable address

        /*
        // transfer (automatically reverts if failed)
        payable(msg.sender).transfer(address(this).balance); 

        // send (does not automatically reverts if failed)
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed"); // to revert
        */

        // call (returns 2 values:- bool and bytes)
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed"); // to revert
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Must be owner to withdraw"); // removed to use if-revert
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        } // saves gas as it only calls the function and not the entire string
        _; // execute contents of calling function
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // function getVersion()  public view returns(uint256) {
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x27B4bB63a9be808c3aABb4484b23CD554451b5bA);
    //     return priceFeed.version();
    // }

    // function getVersion() public view returns (uint256){
    //     AggregatorV31nterface priceFeed = AggregatorV31nterface();
    //     return priceFeed.version();
    // }


    /* fallback
    The fallback function is a special function in Solidity that is called when
    the contract receives a transaction that does not match any other function signature. 
    This can be useful for implementing custom logic that is not handled by any other function
    in the contract.
    */

    /* receive
    The receive function is another special function in Solidity that is called when ether is 
    sent to the contract. This function can be used to receive ether and perform any necessary 
    initialization or other tasks.
    */

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // View / Pure functions (Getters)
    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

    
}
