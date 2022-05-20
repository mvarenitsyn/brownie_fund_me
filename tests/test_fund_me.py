import pytest
from scripts.deploy import deploy_Fundme
from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIROMENTS
from brownie import network, config, accounts, exceptions


def test_can_fund_and_withdraw():
    account = get_account()
    fund_me = deploy_Fundme()
    entrance_fee = fund_me.getEntranceFee() + 100
    print(entrance_fee)
    print(fund_me.getPrice())
    print(f"TX diff {account.balance() - entrance_fee}")
    tx = fund_me.fundme({"from": account, "value": entrance_fee})
    tx.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == entrance_fee
    tx2 = fund_me.withdrawUSD({"from": account})
    tx2.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == 0


def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIROMENTS:
        pytest.skip("only for local testing")

    fund_me = deploy_Fundme()
    bad_actor = accounts.add()
    # fund_me.withdrawUSD({"from": bad_actor})
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdrawUSD({"from": bad_actor})
