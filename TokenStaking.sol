// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract TokenStaking {
  // The address of the token contract that users will be staking.
  address public tokenAddress;

  // The amount of tokens that each user has staked.
  mapping(address => uint) public stakedTokens;

  // The amount of tokens that each user has earned in rewards.
  mapping(address => uint) public earnedTokens;

  // The amount of tokens that each user has claimed from their earned rewards.
  mapping(address => uint) public claimedTokens;

  // The current reward rate, expressed as a decimal (e.g. 0.1 for 10% reward rate).
  // This rate is applied to the amount of tokens that each user has staked to calculate
  // their earned rewards.
  uint public rewardRate;

  // The constructor for the contract, which sets the token contract address and reward rate.
  constructor(address _tokenAddress, uint _rewardRate) public {
    tokenAddress = _tokenAddress;
    rewardRate = _rewardRate;
  }

  // A function that allows users to stake their tokens.
  function stake(uint amount) public {
    // Check that the user has enough tokens to stake the specified amount.
    require(ERC20(tokenAddress).balanceOf(msg.sender) >= amount, "Insufficient tokens");

    // Increase the user's staked token balance by the specified amount.
    stakedTokens[msg.sender] += amount;

    // Transfer the staked tokens from the user's token balance to the contract.
    ERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
  }

  // A function that allows users to claim their earned rewards.
  function claim() public {
    // Calculate the user's earned rewards based on the current reward rate and their staked token balance.
    uint earned = stakedTokens[msg.sender] * rewardRate;

    // Check that the user has enough earned rewards to claim.
    require(earnedTokens[msg.sender] >= earned, "Insufficient earned rewards");

    // Decrease the user's earned rewards balance by the amount being claimed.
    earnedTokens[msg.sender] -= earned;

    // Increase the user's claimed rewards balance by the amount being claimed.
    claimedTokens[msg.sender] += earned;

    // Transfer the claimed rewards from the contract to the user's token balance.
    ERC20(tokenAddress).transfer(msg.sender, earned);
  }
}
