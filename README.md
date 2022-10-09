# Treasure Prototypes

## Developer install

```sh
git submodule update --init --recursive
npm install
curl -L https://foundry.paradigm.xyz | bash # Then follow instructions on screen
```

## Testing
### Hardhat tests
```
yarn install
npx hardhat compile # generates typechain types
npx hardhat test
```

### Foundry tests
`forge test`
