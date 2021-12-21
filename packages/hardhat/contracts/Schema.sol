pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Schema {

//Organization
struct Org {
    bytes32 id;
    string name;
    address owner;
    bytes32[] boards;
    mapping(bytes32 => Board) boardById;
    bool initialized;
}

mapping(bytes32 => Org) public orgById;
Org[] public orgs;

//User
struct User {
    address id;
    mapping(bytes32 => Board) boards;
    mapping(bytes32 => Org) orgs;
}

mapping(address => User) userByAddress;
User[] public users;

//Item
struct Item {
    bytes32 id;
    bytes32 org;
    bytes32 board;
    bytes32 status; 
    bytes32[] metadata;
    string title;
    string description;
    address assignedTo;
}

Item[] public items;
mapping(bytes32 => Item) public itemById;

//Status
struct Status { 
    bytes32 id;
    string title;
    bool initialized;
}

mapping(bytes32 => Status) public statuses;
Status[] public statusList;

//Board
struct Board {
    bytes32 id;
    bytes32 orgId;
    string title;
    Status[] statuses;
    Item[] items;
    address[] admins;
    address[] members;
    bytes32 metadata;
    bool initialized;
}

mapping(bytes32 => Board) public boards;
Board[] public boardList;

}
