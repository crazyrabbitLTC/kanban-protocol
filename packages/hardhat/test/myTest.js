const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let kanban;
  let board;
  let item;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const YourContract = await ethers.getContractFactory("Kanban");
      kanban = await YourContract.deploy();
    });

    describe("createBoard()", function () {
      it("Should create a new board", async function () {
        const columns = ["backlog", "todo", "in progress", "completed"];
        const title = "My Kanban";

        board = await kanban.computeBoardId(title);

        expect(await kanban.createBoard(title, columns))
          .to.emit(kanban, "BoardCreated")
          .withArgs(board, title, columns);
      });
    });

    describe("createItem()", function () {
      it("Should create an item", async function () {
        const title = "First Item";
        const description = "About my first item";

        item = await kanban.computeItemId(title, description);

        expect(await kanban.createItem(board, title, description))
          .to.emit(kanban, "ItemCreated")
          .withArgs(board, item, title, description);

        expect((await kanban.items(item)).id).to.eql(item);
      });
    });

    describe("moveItem()", function () {
      it("Should move an existing item", async function () {
        expect(await kanban.moveItem(item, 2))
          .to.emit(kanban, "ItemMoved")
          .withArgs(item, 2);
      });
    });
  });
});
