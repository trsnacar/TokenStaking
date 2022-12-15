const TokenStaking = artifacts.require("TokenStaking");
const ERC20Mock = artifacts.require("ERC20Mock");
const { expect } = require("chai");

// Set the initial reward rate and token supply.
const INITIAL_REWARD_RATE = 0.1;
const INITIAL_TOKEN_SUPPLY = 1000;

contract("TokenStaking", accounts => {
  let tokenStaking;
  let token;

  beforeEach(async () => {
    // Deploy a new ERC20Mock contract for each test.
    token = await ERC20Mock.new(INITIAL_TOKEN_SUPPLY, { from: accounts[0] });

    // Deploy a new TokenStaking contract for each test, using the deployed ERC20Mock contract.
    tokenStaking = await TokenStaking.new(token.address, INITIAL_REWARD_RATE, { from: accounts[0] });
  });

  it("should stake tokens and earn rewards", async () => {
    // Stake 100 tokens.
    await token.approve(tokenStaking.address, 100, { from: accounts[0] });
    await tokenStaking.stake(100, { from: accounts[0] });

    // Check that the user's staked token balance has increased by 100.
    const stakedTokenBalance = await tokenStaking.stakedTokens(accounts[0]);
    expect(stakedTokenBalance).to.be.bignumber.equal(100);

    // Check that the user's earned rewards balance has increased by 10 (100 * 0.1).
    const earnedTokenBalance = await tokenStaking.earnedTokens(accounts[0]);
    expect(earnedTokenBalance).to.be.bignumber.equal(10);

    // Claim the earned rewards.
    await tokenStaking.claim({ from: accounts[0] });

    // Check that the user's earned rewards balance has decreased by 10.
    const remainingEarnedTokenBalance = await tokenStaking.earnedTokens(accounts[0]);
    expect(remainingEarnedTokenBalance).to.be.bignumber.equal(0);

    // Check that the user's claimed rewards balance has increased by 10.
    const claimedTokenBalance = await tokenStaking.claimedTokens(accounts[0]);
    expect(claimedTokenBalance).to.be.bignumber.equal(10);
  });
});
