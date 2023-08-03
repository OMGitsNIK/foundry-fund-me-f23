// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Address : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI : ✅
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        // return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
        return AggregatorV3Interface(0x27B4bB63a9be808c3aABb4484b23CD554451b5bA).version();
    }
}
