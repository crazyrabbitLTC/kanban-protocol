pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Schema {

    struct Board { 
        bytes32 id; 
        string title;
        mapping(bytes32 => Item) items;
        mapping(address => bool) admins;
        mapping(address => bool) users;
        string[] columns;
    }

    mapping(bytes32 => Board) public boards;

    struct Item {
        bytes32 id;
        bytes32 boardId;
        string title;
        string description;
        uint256 column;
        address owner;
    }

    mapping(bytes32 => Item) public items;

}
