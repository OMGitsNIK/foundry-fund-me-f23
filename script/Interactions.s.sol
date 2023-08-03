// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // vm.startBroadcast();
        fundFundMe(mostRecentDeployed);
        // vm.stopBroadcast();
    }

    function fundFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();  
        vm.stopBroadcast();    
        console.log("Funded FundMe with %s ", SEND_VALUE);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployed)).withdraw();      
        vm.stopBroadcast();
        //console.log("Funded FundMe with %s ", SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // vm.startBroadcast();
        withdrawFundMe(mostRecentDeployed);
        // vm.stopBroadcast();
    }

    
}
