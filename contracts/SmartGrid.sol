// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartGrid {
    address public owner;
    mapping(address => bool) public isSeller;
    mapping(address => uint256) public energyBalance;
    uint256 public energyPricePerKWh = 0.01 ether;

    mapping(address => uint256) public userCredits;

    event CreditStored(address indexed user, uint256 credits);
    event EnergyPurchased(address indexed buyer, address indexed seller, uint256 kWh, uint256 cost);

    constructor() {
        owner = msg.sender;
    }

    modifier onlySeller() {
        require(isSeller[msg.sender], "Not a seller");
        _;
    }

    function registerSeller() external {
        isSeller[msg.sender] = true;
    }

    function unregisterSeller() external {
        isSeller[msg.sender] = false;
    }

    function depositEnergy(uint256 kWh) external onlySeller {
        energyBalance[msg.sender] += kWh;
    }

    function purchaseEnergy(address seller, uint256 kWh) external payable {
        require(isSeller[seller], "Seller is not registered");
        require(energyBalance[seller] >= kWh, "Seller does not have enough energy");

        uint256 cost = kWh * energyPricePerKWh;
        require(msg.value >= cost, "Insufficient funds sent");

        payable(seller).transfer(cost);

        energyBalance[seller] -= kWh;

        emit EnergyPurchased(msg.sender, seller, kWh, cost);
    }

    function storeCredit(address user, uint256 credits) external {
        require(credits >= 1, "Credits must be greater than or equal to 1 to be stored on the blockchain");
        userCredits[user] += credits;
        emit CreditStored(user, credits);
    }

    function getCredits(address user) external view returns (uint256) {
        return userCredits[user];
    }
}
