const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('RockPaperScissors', () => {
    let RockPaperScissors;
    let rockPaperScissors;
    let owner;
    let player1;
    let player2;

    beforeEach(async () => {
        [owner, player1, player2] = await ethers.getSigners();
        RockPaperScissors = await ethers.getContractFactory('RockPaperScissors');
        rockPaperScissors = await RockPaperScissors.deploy();
        await rockPaperScissors.deployed();
    });

    it('should allow players to join the game', async () => {
        await rockPaperScissors.connect(player1).joinGame();
        const result = await rockPaperScissors.player2();
        expect(result).to.equal(player1.address);
    });

    it('should not allow the same player to join twice', async () => {
        await rockPaperScissors.connect(player1).joinGame();
        await expect(rockPaperScissors.connect(player1).joinGame()).to.be.revertedWith('Game is full');
    });

    it('should not allow a player to submit move before the game starts', async () => {
        await expect(rockPaperScissors.connect(player1).submitMove(1)).to.be.revertedWith('Game has not started yet');
    });

    it('should allow players to submit moves after the game starts', async () => {
        await rockPaperScissors.connect(player1).joinGame();
        await rockPaperScissors.connect(player2).joinGame();

        await rockPaperScissors.connect(player1).submitMove(1); // Player 1: Rock
        await rockPaperScissors.connect(player2).submitMove(2); // Player 2: Paper

        const result1 = await rockPaperScissors.moves(player1.address);
        const result2 = await rockPaperScissors.moves(player2.address);

        expect(result1).to.equal(1);
        expect(result2).to.equal(2);
    });

    it('should determine the winner correctly', async () => {
        await rockPaperScissors.connect(player1).joinGame();
        await rockPaperScissors.connect(player2).joinGame();

        await rockPaperScissors.connect(player1).submitMove(1); // Player 1: Rock
        await rockPaperScissors.connect(player2).submitMove(2); // Player 2: Paper

        await ethers.provider.send('evm_increaseTime', [60 * 60 * 24 + 1]); // Advance time to trigger game end

        const tx = await rockPaperScissors.connect(player1).determineWinner();
        const event = tx.events[0];
        expect(event.event).to.equal('GameResult');
        expect(event.args.winner).to.equal(player2.address);
        expect(event.args.move).to.equal(2);
    });

    it('should handle a tie correctly', async () => {
        await rockPaperScissors.connect(player1).joinGame();
        await rockPaperScissors.connect(player2).joinGame();

        await rockPaperScissors.connect(player1).submitMove(1); // Player 1: Rock
        await rockPaperScissors.connect(player2).submitMove(1); // Player 2: Rock

        await ethers.provider.send('evm_increaseTime', [60 * 60 * 24 + 1]); // Advance time to trigger game end

        const tx = await rockPaperScissors.connect(player1).determineWinner();
        const event = tx.events[0];
        expect(event.event).to.equal('GameResult');
        expect(event.args.winner).to.equal(ethers.constants.AddressZero);
        expect(event.args.move).to.equal(1);
    });
});

