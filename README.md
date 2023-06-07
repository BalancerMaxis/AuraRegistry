# AuraRegistry
#### A permissionless helper contract that allows you to get the aura booster pid for a certain Balancer gauge

The contract makes the assumption that if there are two separate pids for the same gauge, the higher pid takes priority. 

`gaugeDetails`: a struct consisting of 
`address lpToken, uint8 pid;`

`poolList[gauge]`: A mapping of gaugeDetails structs by gauge

`addGauge(uint8 pid)`: Derives the gauge from the pid by calling booster.poolInfo(pid) and stores the pid+lptoken in poolList(gauge), mapped by gauge

`addManyGauges(uint8[] pids)`: loops through the array of pids and calls addpool for each, note that a supplied pid must not yet be added lest it revert

`updatePidForGauge(uint8 pid, address gauge)`: derives the gauge of supplied pid through booster.poolInfo(pid) and checks the poolList mapping to see if the supplied pid is higher than stored pid and updates it.  

`updateManyGauges(needUpdate[] list)` updates many gauges.  list is an array of needUpdate structs `address gauge, uint8 pid'

`validateList(uint8 lowerBound, uint8 upperBound)` A view function that iterates through the supplied pid ranges to see if any stored pids for a gauge need updating. Returns looks like this:
`('0xe2b680A8d02fbf48C7D9465398C4225d7b7A7f87', 99), ('0x0312AA8D0BA4a1969Fddb382235870bF55f7f242', 101))` indicating which gauges need their pid updated

**NOTE** This is meant to be called offchain by keepers 

`getLPFromPid(pid)`: Get the lp token for a certain pid

`getPidFromGauge(gauge)` looks up gauge in poolList and returns the pid

`removeShutdownGauge(pid)` removes the mapping in poolList if booster.poolInfo(pid).shutdown ==true and supplied pid matches the stored pid 

Some notes:
* Upon deployment, someone will have to populate poolList with all the gauges.  

* validateList upper bound must not be more than the max pid of the booster

* line 56 (which checks if a pid has been shutdown) has been edited out for testing purposes

* Pid of 0 does not work because of how solidity defaults an unmapped item to 0.  which is fine since 0 is the shutdown aura/weth gauge