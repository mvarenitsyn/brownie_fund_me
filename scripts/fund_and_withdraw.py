from brownie import FundMe
from scripts.helpful_scripts import get_account


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee() + 100
    # print(entrance_fee)
    print(f"Current entrance fee is {entrance_fee}")
    print("Funding")
    fund_me.fundme({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    print("Withdraw everything")
    fund_me.withdrawUSD({"from": account})
    print("Done")


def main():
    fund()
    withdraw()
