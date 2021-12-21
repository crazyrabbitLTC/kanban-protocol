pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./Schema.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Kanban is Schema {
    event OrgUpdated(string Name, address indexed Owner, uint256 BoardCount);
    event StatusCreated(string Title, bytes32 Id);
    event BoardCreated();
    event UserUpdated(
        address indexed User,
        uint256 OrgCount,
        uint256 BoardCount
    );
    event ItemStatusUpdated(bytes32 indexed id, bytes32 indexed status);

    event ItemCreated(
        bytes32 indexed id,
        bytes32 indexed org,
        bytes32 indexed status,
        bytes32[] metadata,
        string title,
        string description,
        address assignedTo
    );

    // Things that are created once
    function findOrCreateUser(address _user) public returns (address) {
        if (userByAddress[_user].id == address(0)) {

            User storage user;
            
            user.id = _user;

            userByAddress[_user] = user;
            users.push(user);

            emit UserUpdated(_user, user.orgs.length, user.boards.length);
        }

        return (userByAddress[_user]).address;
    }

    function findOrCreateStatus(string calldata _title)
        public
        returns (Status calldata)
    {
        if (!statuses[computeStatusId(_title)].initialized) {
            Status memory status = Status({
                id: computeStatusId(_title),
                title: _title,
                initialized: true
            });

            statuses[computeStatusId(_title)] = status;
            statusList.push(status);

            emit StatusCreated(_title, computeStatusId(_title));
        }

        return statuses[computeStatusId(_title)];
    }

    function findOrCreateOrg(string calldata _name, address _owner)
        public
        returns (Org calldata)
    {
        require(_name != "", "Err: Org name requires a string");

        bytes32 orgId = computeOrgId(_name, _owner);
        address owner = findOrCreateUser(_owner);

        if (!orgById[orgId].initialized) {
            Board[] memory emptyBoard;
            Org memory newOrg = Org({
                id: orgId,
                name: _name,
                owner: owner,
                boards: bytes32[],
                initialized: true
            });

            orgs.push(newOrg);
            orgById[orgId] = newOrg;
            emit OrgUpdated(_name, _owner, newOrg.boards.length);
        }

        return orgById[orgId];
    }

    // Things that are created and can be updated

    function findItem(bytes32 id) public returns (Item memory) {
        return itemById[id];
    }

    function updateItemStatus(bytes32 id, bytes32 status)
        public
        returns (Item memory)
    {
        require(itemById[id].id, "err, Item does not exist");

        //require this status exists on the board
        // require()

        itemById[id].status = status;
        emit ItemStatusUpdated(id, status);
        return itemById[id];
    }

    function createItem(
        bytes32 _org,
        bytes32 _board,
        bytes32 _status,
        bytes32[] calldata _metadata,
        string calldata _title,
        string calldata _description,
        address _assignedTo
    ) public returns (Item memory) {

        //require board exists
        //require org exists

        bytes32 id = keccak256(
            abi.encode(block.blockhash(block.number), _title, _description)
        );

        Item memory item = Item({
            id: id,
            org: _org,
            board: _board,
            status: _status,
            metadata: _metadata,
            title: _title,
            description: _description,
            addignedTo: findOrCreateUser(_assignedTo).id
        });

        items.push(item);
        itemById[id] = item;

        emit ItemCreated(
            id,
            _org,
            _board,
            _status,
            _metadata,
            _title,
            _description,
            _assignedTo
        );

        return item;
    }

    function findBoard(bytes32 id) public returns (Board memory){
        return boards[id];
    }

    function createBoard(
        string memory _title, 
        bytes32 _orgId,
        bytes32[] memory _statuses, 
        address[] memory _admins,  
        address[] memory _members, 
        bytes32 _metadata) public returns(Board memory) {

        bytes32 id = keccak256(
            abi.encode(block.blockhash(block.number), _title, _metadata)
        );

        //require statuses exist
        //require that orgId exists
        //require that creator has permission


        // make each admin a user

        Item memory emptyItemList = new Item[];

        Board memory board = Board({
            id: id,
            orgId: _orgId,
            title: _title,
            statuses: _statuses,
            items: emptyItemList,
            admins: _admins,
            members: _members,
            metadata: _metadata,
            initialized: true
        });

        // make each Member a user
        for(uint x = 0; x < _members.length; x++){
            User memory member = findOrCreateUser(_members[x]);

            // add this board to them
            member.boards[id] = board;

            // add this org to them
            member.orgs[_orgId] = board;
        }

        // make each admin a user
        for(uint x = 0; x <  _admins.length; x++){
            User memory admin = findOrCreateUser(_admins[x]);

            // add this board to them
            admin.boards[id] = board;

            // add this org to them
            admin.orgs[_orgId] = orgById[_orgId];
        }

        // Save the board
        boards[id] = board;
        boardList.push(board);
    }

    // ComputeID's

    function computeStatusId(string calldata _title)
        internal
        returns (bytes32)
    {
        return keccak256(abi.encode(_title));
    }

    function computeOrgId(string calldata _name, address _owner)
        internal
        returns (bytes32)
    {
        return keccak256(abi.encode(_name, _owner));
    }

    // function findOrCreateOrg()
    // function findOrCreateItem()
    // function findOrCreateStatus()
    // function findOrCreateUser()
}
