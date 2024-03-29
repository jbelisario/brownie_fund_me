from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import (
    deploy_mocks,
    get_account,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)

# brownie run scripts/deploy.py --network rinkeby
def deploy_fund_me():
    account = get_account()
    # pass the price feed address to our fundMe contract

    # if we are on a persistent network like rinkeby, use the associated address
    # otherwise, deploy mocks (test folder) --- if we're not on a dev network, pull the address right from config
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        # use the most recently deployed MockV3Aggregator
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address
    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
