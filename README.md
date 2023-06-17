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
TODO
## 6. Selfie
Firstly, you have flash loan enough amount of token so that you can have a right to vote which is greater than 50% of the token's total supply.
Secondly, wait for 2 day so that we can call `executeAction()` to drain the contract
    - Checkbox
        + increase time in hardhat:
        + call `token.snapshot()` in `onFlashLoan()`:

## 7. Compromised
Turn out, those two `strange` strings is actually two decoded privatekeys of two trusted reporters
To encode it, you have to first transfer it from hex to text string, and then decoded it using base64 algothirm which is commonly used in web development(but if you have never heard of it, it's fine)
When you successfully claimed those private keys, you can manipulate price of the NFT whenever you want
The price oracle is always pick the middle price of those 3 trusted reporter. This mean that if those trusted reported `postPrice()` like this: 1, 1, 1000 ether then the price is 1

What you have to do is change the price of NFT to 1, buy it, then set it to the balance of the exchange and sell the NFT
    - Checkbox
        + Oracle:
        + Base64:
        + Encode, decode:
        + Hex to text:
        + Contract factory:
## 8. Puppet
Since original uniswap v1 is a Vyper contract, this one is painnnnnn. To solve this one you have to make an attack contract that able to do this step:
    Step 1: transfer all token to the attack contract
    Step 2: approve uniswap pair using token in attack contract
    Step 3: Swap all token to ETH using uniswap
    Step 4: Using all ETH to borrow all token 
    Step 5: 
        + If we have drained the pool contract, go to step 6
        + If not, going back to step 3
    Step 6: Swap all ETH to token, draining majority amount of token of the pair
    Step 7: Transfer all the token to the player

This can be solve in different ways, but the overall answer is: swap it, borrow it, swap it, borrow it,...

Why this challenge is allowed player using only one transaction?
    - Player start with 25 ETH and 1000 DVTs, this make player have to use only one asset
    - Have to make other wallet deploy the attack contract for player
    - Make player have to use attack contract

    - Checkbox:
        + Think of the overall answer but the code is not running
        + Pass the first assertion (Player executed a single transaction)
        + Using `while/for` in the attack function
        + Uniswap v1
        + Read the contract uniswap v1 in vyper
        + x * y = k
## 9. Puppet V2

The exploit idea of V2 is exactly like v1: swap it, borrow it, swap it, borrow it,...
The difference here is how you implement uniswap v2, using WETH instead of ETH, using Uniswap Router,...

Fee is 0%

<!-- Action| Player ETH | Player DVT | Uniswap ETH | Uniswap DVT | Lending Pool ETH | Lending Pool ETH |Price ETH/DVT|
|--|----------|----------|----------|----------|----------|----------|---|
|Initial|   20 |   10000 |   10 |   100 |   0 |   1000000 | 10
|Swap 10000 DVT->ETH  |   29,901 |   0 |   0,099 |   10100 |   0 |   1000000 | 102020,2   
|Borrow DVT  |   20,099 |   **1000000** |   0,099 |   10100 |   9.802 |   **0** | 102020,2    -->

    - Checkbox:
        + Change solidity
        + Uniswap V2
        + Wrapped token
        + Using UniswapV2Router02
        + Know why not using UniswapV2Router01
## 10. Free Rider
## 11. Backdoor
## 12. Climber
## 13. Wallet Mining
## 14. Puppet V3
## 15. ABI Smuggling