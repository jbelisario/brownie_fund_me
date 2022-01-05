from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]

DECIMALS = 8
STARTING_PRICE = 200000000000


def get_account():
    # if we work on a dev chain, we use accounts[0]
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:  # pull from config
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying Mocks...")
    # MockV3Aggregator is a list of every MockV3Aggregator we deploy
    if len(MockV3Aggregator) <= 0:
        # MockV3Aggregator.deploy(
        #     DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": get_account()}
        # )
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})

    print("Mocks Deployed!")


"""
Create Mainnet fork
brownie networks add development mainnet-fork-dev cmd=ganache-cli host=http://127.0.0.1 fork=https://eth-mainnet.alchemyapi.io/v2/ml9L67S721OrDYEZinIElS4Iir4lKu7K  accounts=10 mnemonic=brownie port=8545 
"""
