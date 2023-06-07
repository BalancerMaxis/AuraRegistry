import brownie
import time
from brownie import chain, Contract
import pytest
import random


ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

def test_deploy(deploy):
    return



def test_getLPFromPid(deploy):
    pid = 97
    lp = "0x20a61B948E33879ce7F23e535CC7BAA3BC66c5a9"
    gauge = "0x6F3b31296FD2457eba6Dca3BED65ec79e06c1295"
    test = deploy.getLPFromPid(pid)
    assert(test == lp)

def test_addGauge(deploy, booster):
    pid = 97
    gauge= "0x6F3b31296FD2457eba6Dca3BED65ec79e06c1295"
    deploy.addGauge(pid)
    lp = "0x20a61B948E33879ce7F23e535CC7BAA3BC66c5a9"
    assert deploy.poolList(gauge) == (lp,pid)
    # assert False

# need to know how to clear state after this
# def test_updatePid(deploy, booster):
#     deploy.addGauge(1)

# this test takes forever so leave it last
# def test_validateList(deploy, booster):
#     deploy.addGauge(1)
#     assert(deploy.poolList(booster.poolInfo(1)[2])[1] == 1 )
#     assert(deploy.validateList(1, 102)[0] == ('0x0312AA8D0BA4a1969Fddb382235870bF55f7f242', 101))
#     deploy.updatePidForGauge(101,'0x0312AA8D0BA4a1969Fddb382235870bF55f7f242')
#     assert(deploy.poolList('0x0312AA8D0BA4a1969Fddb382235870bF55f7f242')[1] == 101)


def testAddAll(deploy, booster):
    topPid = 102
    for i in range(topPid):
        try:
            deploy.addGauge(i)
        except:
            print("f")
    assert (deploy.poolList("0x0312AA8D0BA4a1969Fddb382235870bF55f7f242")[1] == 1)

    for i in range(topPid):
        try:
            deploy.updatePidForGauge(i)
        except:
            print("f")

    assert False
# def test_addManyPools(deploy, booster):


