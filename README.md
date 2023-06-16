![](cover.png)

**A set of challenges to learn offensive security of smart contracts in Ethereum.**

Featuring flash loans, price oracles, governance, NFTs, lending pools, smart contract wallets, timelocks, and more!

## Play

Visit [damnvulnerabledefi.xyz](https://damnvulnerabledefi.xyz)

## Support

For Q&A, support and troubleshooting running Damn Vulnerable DeFi, go [here](https://github.com/tinchoabbate/damn-vulnerable-defi/discussions/categories/support-q-a-troubleshooting).

## Disclaimer

All Solidity code, practices and patterns in this repository are DAMN VULNERABLE and for educational purposes only.

DO NOT USE IN PRODUCTION.

## Scoring system appreciate for thinking hard enough
It's almost impossible to complete it on the first try (unless you're a pro, who would never go to this repo, lol). Sometimes you're so close to the answer but somehow missed it or lacked some knowledge to solve it, and then when you look at the answer, you feel frustrated. This scoring system is a nicer approach for acknowledging your research efforts compared to the usual solved/not solved scoring system.

For each challenge, the maximum score gained is 1 point. Each solved challenge automatically earns 1 point.
## 1. Upstoppable
    Donating some token to the vault will make this line broken
    
    ```if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement```

    - Checkbox
        + Reentrancy:
        + ERC20:
        + ERC4626: 
        + ERC3156:
        + know what this is doing: 
        ```assembly { // better safe than sorry
            if eq(sload(0), 2) {
                mstore(0x00, 0xed3ba6a6)
                revert(0x1c, 0x04)
            }
        }```
        + OnlyOwner modifier
## 2. Naive receiver
    Just call `flashLoan()` 10 times
    To make it in one transaction, deploy the custom contract that call `flashLoan()` 10 times 

    - Checkbox:
        + Create attacker contract:
        + Payable function:
        + SafeTransferLib:
        + receive/fallback function:
        + Know what this is doing:
        ```
        assembly { // gas savings
            if iszero(eq(sload(pool.slot), caller())) {
                mstore(0x00, 0x48f5c3ed)
                revert(0x1c, 0x04)
            }
        }
        ```

## 3. Truster
    Notice this line in TrusterLenderPool.sol:

`target.functionCall(data);`

You can make the lender approve the maximum amount of token to the attacker contract, and after that you can just withdraw it to our wallet
    - Checkbox:
        + Low-level call:
        + Encode low-level call
            * using js/ts (hardhat)
            * using solidity

## 4. Side Entrace
Firstly, we have to flashloan the maximum amount (1000 ether). The trick here is in the `execute()` of our attacker, we will call `deposit()` with 1000 ether, making `balances[msg.sender]` is 1000 ether after flashloan end. After that, we will simply `withdraw()`, draining the pool
    - Checkbox
        + unchecked
        + ...TODO
## 5. The Rewarder

## 6. Selfie
## 7. Compromised
## 8. Puppet
## 9. Puppet V2
## 10. Free Rider
## 11. Backdoor
## 12. Climber
## 13. Wallet Mining
## 14. Puppet V3
## 15. ABI Smuggling