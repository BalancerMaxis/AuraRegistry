bbausd_gauge = "0x3Eae4a1c2E36870A006E816930d9f55DF0a72a13"

bbamusd_gauge = "0x3Eae4a1c2E36870A006E816930d9f55DF0a72a13"
gauge = Contract(bbamusd_gauge)

pweth = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619"


calldata = "0xe8de0d4d000000000000000000000000c3c7d422809852031b44ab29eec9f1eff2a587560000000000000000000000006951b5bd815043e3f842c1b026b0fa888cc2dd85"


pmsig = "0xeE071f4B516F69a1603dA393CdE8e76C40E5Be85"
plm = "0xc38c5f97B34E175FFd35407fc91a937300E33860"


ldowhale = "0x8565faab405b06936014c8b6bd5ab60376cc051b"
polyldo = "0xC3C7d422809852031b44ab29EEC9F1EfF2A58756"

ldo = Contract(polyldo)

deployer = accounts[0]


pauthadapt = "0xAB093cd16e765b5B23D34030aaFaF026558e0A19"
authadapt = Contract(pauthadapt)

tx = gaugep.add_reward(polyldo,injector,{'from':plm})
auth.performAction(bbamusd_gauge,tx.input,{'from':plm})

victim = "0x62ac55b745f9b08f1a81dcbbe630277095cf4be1"
rtoken.transfer(deployer, 20 * 10 ** 18, {'from': victim})

rtoken.transfer()

gaugep.deposit_reward_token(pweth,2 * 10 ** 18,{'from':deployer})

periodfinish\

(distributor,period_finish,rate,lastUpdate,integral) = gaugep.reward_data(pweth)
