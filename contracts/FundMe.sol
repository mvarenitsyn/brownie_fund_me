//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    mapping(address => uint256) public addressToAmountFunded;

    function fundme() public payable {
        uint256 minUsd = 10 * 10**18;
        require(getCovertedValue(msg.value) >= minUsd, "Not enough ether!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    function getCovertedValue(uint256 _payableAmount)
        public
        view
        returns (uint256)
    {
        uint256 price = getPrice();
        uint256 getAmountUSD = (price * _payableAmount) / 10000000;
        return getAmountUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only Megaboss can withdraw");
        _;
    }

    function withdrawUSD() public payable onlyOwner {
        //require(owner == msg.sender, "Only Megaboss can withdraw");
        payable(msg.sender).transfer(address(this).balance);
        for (
            uint256 FunderIndex = 0;
            FunderIndex < funders.length;
            FunderIndex++
        ) {
            address funder = funders[FunderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
