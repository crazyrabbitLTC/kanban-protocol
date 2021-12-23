pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./Schema.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Kanban is Schema {
    event BoardCreated(bytes32 indexed id, string Title, string[] Columns);

    event ItemCreated(
        bytes32 indexed BoardId,
        bytes32 indexed ItemId,
        string Title,
        string Description
    );
    event ItemMoved(bytes32 indexed ItemId, uint256 Column);
    event ItemDeleted(bytes32 indexed ItemId, address Deleter);

    modifier onlyBoardPermission(bytes32 _id) {
        require(
            boards[_id].admins[msg.sender],
            "err: caller does not have board permission"
        );

        _;
    }

    modifier onlyItemPermission(bytes32 _id) {
        require(
            items[_id].owner == msg.sender,
            "err: caller does not own item"
        );
        _;
    }

    modifier onlyItemOrBoardPermission(bytes32 _id) {
        bool isBoardAdmin = boards[_id].admins[msg.sender];
        bool isItemOwner = items[_id].owner == msg.sender;
        require(
            isBoardAdmin || isItemOwner,
            "err: caller does not have permission to edit"
        );
        _;
    }

    modifier onlyBoardAdminOrUserPermission(bytes32 _id) {
        bool isBoardAdmin = boards[_id].admins[msg.sender];
        bool isBoardUser = boards[_id].users[msg.sender];
        _;
    }

    function createBoard(string memory _title, string[] memory _statusColumns)
        public
    {
        //Id
        bytes32 id = keccak256(abi.encode(_title));

        //Create Struct
        Board storage board = boards[id];

        board.id = id;
        board.title = _title;
        board.columns = _statusColumns;

        //emit event
        emit BoardCreated(id, _title, _statusColumns);
    }

    function createItem(
        bytes32 _boardId,
        string memory _title,
        string memory _description
    ) public onlyBoardAdminOrUserPermission(_boardId) {
        //Id
        bytes32 id = keccak256(abi.encode(_title, _description, _boardId));

        //Require item does not already exist with Title and Description
        //Todo: find a better way to generate IDs
        require(
            items[id].id != 0,
            "err: item with same title and description already exists"
        );

        //Create Struct
        Item storage item = items[id];

        item.id = id;
        item.boardId = id;
        item.title = _title;
        item.description = _description;
        item.column = 0;

        //emit event
        emit ItemCreated(_boardId, id, _title, _description);
        emit ItemMoved(id, 0);
    }

    function moveItem(bytes32 _itemId, uint256 _column)
        public
        onlyItemOrBoardPermission(_itemId)
    {
        items[_itemId].column = _column;

        emit ItemMoved(_itemId, _column);
    }

    function deleteItem(bytes32 _itemId)
        public
        onlyItemOrBoardPermission(_itemId)
    {
        require(items[_itemId].id != 0, "err: item does not exist");

        items[_itemId].id = 0;
        items[_itemId].boardId = 0;
        items[_itemId].title = "";
        items[_itemId].description = "";
        items[_itemId].column = 0;

        emit ItemDeleted(_itemId, msg.sender);
    }
}
