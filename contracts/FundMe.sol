// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

// brownie isn't aware of NPM packets but CAN download from github
// use pkg for downloading chainlink contracts
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

/*
interfaces compile down to "ABI" (application binary interface) 
ABI - tells solidity and other prog langs how it can interact with another contract
*/

// accept some sort of payment & keep track of who paid me
contract FundMe {
    using SafeMathChainlink for uint256; // doesn't allow overflow to occur

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    //constructor = gets called instant SC is deployed
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender; //b/c sender = whoever deploys this sc
        // tell it what price feed address we should use
    }

    //payable = fxn can be used to pay for things
    function fund() public payable {
        uint256 minUSD = 50 * 10**18; // 10 ** 18 = $50 in GWEI
        //if not true, execute a revert meaning they get their money back as well as any unspent gas
        require(getConversionRate(msg.value) >= minUSD, "Min spend = $50");
        // msg.sender = sender of the fxn call
        // msg.value = is how much they sent
        addressToAmountFunded[msg.sender] += msg.value; // keep track of how much account is funding contract
        // what the ETH -> USD conversion rate is
        funders.push(msg.sender); // and who is funding the contract
    }

    //create a minimum value for people to fund [in another currency]

    function getVersion() public view returns (uint256) {
        // "we have a contract with the fxns defined in the interface located at this address
        // if thats true, we should be able to call:
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000); //wei to gwei i believe
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    //modifier = used to change the behavior of a fxn in a declarative way.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _; //run the require first then the rest of the code
    }

    function withdraw() public payable onlyOwner {
        //fxn we can call on any addy to send eth from one to another.
        //"this" = the contract you're currently in -- address(this) = addy of the contract we're in
        msg.sender.transfer(address(this).balance); //transfer ETH to msg.sender (our wallet)

        //want to set everyones balance in the mapping to 0
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //set funders to a new address array to "clear" it.
        funders = new address[](0);
    }
}
