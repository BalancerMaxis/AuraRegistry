import pytest
import time
from brownie import (
    interface,
    accounts,
    gaugeRegistry,
    Contract

)
from dotmap import DotMap
import pytest


##  Accounts
## addresses are for polygon

BOOSTER = "0xA57b8d98dAE62B26Ec3bcC4a365338157060B234"


@pytest.fixture(scope="module")
def admin():
    return ARBI_LDO_WHALE

@pytest.fixture(scope="module")
def deployer():
    return accounts[0]

@pytest.fixture(scope="module")
def booster():
    return Contract(BOOSTER)

@pytest.fixture()
def injector(deploy):
    return deploy.injector



@pytest.fixture(scope="module")
def deploy(deployer):
    """
    Deploys, vault and test strategy, mock token and wires them up.
    """

    # token.transfer(admin, 10000*10**18, {"from": ARBI_LDO_WHALE})

    injector = gaugeRegistry.deploy(
        {"from": deployer}
    )

    return injector


