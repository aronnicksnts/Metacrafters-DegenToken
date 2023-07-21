// SPDX-License-Identifier: MIT
// 1. Only owner should be able to mint tokens
// 2. Players should be able to transfer tokens to each other
// 3. Players should be able to redeem items with their tokens
// 4. Players should be able to check their token balance
// 5. Players should be able to burn tokens
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "hardhat/console.sol";

contract DegenToken is ERC20, Ownable, ERC20Burnable {
    mapping(uint256=> uint256) public itemPrices;
    mapping(uint256=> string) public itemNames;
    uint256[] public itemIds;
    mapping(address => uint256[]) public userItems;

    constructor() ERC20("Degen", "DGN") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function getBalance() external view returns (uint256){
        return this.balanceOf(msg.sender);
    }

    function transferTokens(address _to, uint256 _value) external {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens to Transfer the amount of tokens");
        approve(msg.sender, _value);
        transferFrom(msg.sender, _to, _value);
    }

    function burnTokens(uint256 _value) external {
        require(balanceOf(msg.sender) >= _value, "You do not have enough Degen Tokens to burn");
        approve(msg.sender, _value);
        _burn(msg.sender, _value);
    }

    function addItemToStore(uint256 itemId, uint256 price, string memory itemName) public onlyOwner {
        itemPrices[itemId] = price;
        itemNames[itemId] = itemName;
        itemIds.push(itemId);
    }

    function redeemItem(uint256 itemId) external {
        uint256 priceOfItem = itemPrices[itemId];

        require(priceOfItem > 0, "Item not found or price has not been set");
        require(balanceOf(msg.sender) >= priceOfItem, "Not enough Degen Tokens to redeem the said item");
        approve(msg.sender, priceOfItem);
        transferFrom(msg.sender, owner(), priceOfItem);

        userItems[msg.sender].push(itemId);
    }

    function checkItems() external view returns (string[] memory){
        uint256 itemCount = itemIds.length;
        string[] memory items = new string[](itemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            uint256 itemId = itemIds[i];
            string storage itemName = itemNames[itemId];
            // Convert the uint to a string and concatenate with "\n"
            items[i] = string(abi.encodePacked("itemId: ", itemId, "\n", "itemName: ", itemName, "\n\n"));
        }

        return items;
    }


    function getUserItems() external view returns (string[] memory) {
        uint256 itemCount = userItems[msg.sender].length;
        string[] memory items = new string[](itemCount);

        for (uint256 i = 0; i < itemCount; i++) {
            uint256 itemId = userItems[msg.sender][i];
            string storage itemName = itemNames[itemId];
            // Convert the uint to a string and concatenate with "\n"
            items[i] = string(abi.encodePacked(itemName, "\n"));
        }

        return items;
    }
}
