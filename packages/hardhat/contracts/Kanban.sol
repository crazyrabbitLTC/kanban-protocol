pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./Schema.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Kanban is Schema {
    event BoardCreated(string Title, string[] Columns);

    event ItemCreated(
        bytes32 indexed BoardId,
        bytes32 indexed ItemId,
        string Title,
        string Description
    );
    event ItemMoved(bytes32 indexed ItemId, uint256 Column);

    function createBoard(string memory _title, string[] memory _columns)
        public
    {
        //Id
        bytes32 id = keccak256(abi.encode(_title));

        //Create Struct
        Board storage board = boards[id];

        board.id = id;
        board.title = _title;
        board.columns = _columns;

        //emit event
        emit BoardCreated(_title, _columns);
    }

    function createItem(
        bytes32 _boardId,
        string memory _title,
        string memory _description
    ) public {
        //Id
        bytes32 id = keccak256(abi.encode(_title, _description));

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

    function moveItem(bytes32 _itemId, uint256 _column) public {
        items[_itemId].column = _column;

        emit ItemMoved(_itemId, _column);
    }
}
