// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./../interfaces/IBooster.sol";



/**
 * @title Aura Registry
 * @author mike b
 * @notice registry for aura booster to get pid by gauge
 * @notice allows anyone to call addgauge to add the gauge to poolList
 * @notice if there exists a gauge for which there is a corresponding pid that is higher than stored, you can call updatePidForGauge
 */
contract gaugeRegistry {

    IBooster booster = IBooster(0xA57b8d98dAE62B26Ec3bcC4a365338157060B234);


    struct GaugeDetails {
        address lpToken;
        uint8 pid;
    }

    struct NeedUpdate {
        address gauge;
        uint8 pid;
    }

    mapping(address => GaugeDetails) public poolList;
    address[] public gaugeList;

    //    function getPoolInfo(uint8 pid) internal returns (GaugeDetails memory){
    //        return GaugeDetails(booster.poolInfo(pid).lptoken,booster.poolInfo(pid).gauge;
    //    }
    //
    function getLPFromPid(uint8 pid) public view returns (address){
        return (booster.poolInfo(pid).lptoken);
    }

    function getMaxPid() public view returns (uint256){
        return (booster.poolLength() - 1);
    }

    function getPidFromGauge(address gauge) public view returns (uint8){
        return (poolList[gauge].pid);
    }

    // makes sure that the pid's gauge does not have an item in poolList for it
    function addGauge(uint8 pid) public {
        if(poolList[booster.poolInfo(pid).gauge].pid != 0
        // edit out for testing    || booster.poolInfo(pid).shutdown == true
        ){
            revert("pool already exists for gauge");
        }
        poolList[booster.poolInfo(pid).gauge] = GaugeDetails(booster.poolInfo(pid).lptoken, pid);
        gaugeList.push(booster.poolInfo(pid).gauge);
    }

    function updatePidForGauge(uint8 pid, address gauge) public {
        if(poolList[booster.poolInfo(pid).gauge].pid == 0) {
            revert("gauge not initiated, use addGauge");
        }
        // check: supplied pid is greater than current stored pid for gauge
        // && the supplied gauge matches gauge derived from the stored pid
        // && check that the gauge of the new pid matches the gauge of the old pid
        // probably don't need second check since the gauge is directly returned from booster.poolInfo in addpool
        if(pid > poolList[gauge].pid &&
        gauge == booster.poolInfo(poolList[gauge].pid).gauge &&
        booster.poolInfo(pid).gauge == booster.poolInfo(poolList[gauge].pid).gauge
        ) {
            poolList[gauge] = GaugeDetails(booster.poolInfo(pid).lptoken, pid );
        } else {
            revert("unable to update pid");
        }
    }

    // view function to iterate through all pids and see if the derived gauge is stored in poolList
    // then check if the poolList[gauge] needs its pid updated to a higher value
    function validateList(uint8 lowerBound, uint8 upperBound) public view returns (NeedUpdate[] memory) {

        NeedUpdate[] memory badGauges = new NeedUpdate[](upperBound - lowerBound);
        uint256 counter = 0;

        for (uint8 idx = lowerBound; idx < upperBound; idx++) {
            // check if idx is higher than stored pid in poolList(gauge)
            if (idx > poolList[booster.poolInfo(idx).gauge].pid &&
            poolList[booster.poolInfo(idx).gauge].pid != 0)
            {
                NeedUpdate memory test = NeedUpdate(booster.poolInfo(idx).gauge, idx);
                badGauges[counter] = test;
                counter++;
            }
        }
        assembly {
            mstore(badGauges, counter)
        }

        return badGauges;
    }

    function addManyGauges(uint8[] memory pids) public {
        for (uint8 idx = 0; idx < pids.length; idx++) {
            addGauge(pids[idx]);
        }
    }

    function updateManyGauges(NeedUpdate[] memory list) public {
        for (uint8 idx = 0; idx < list.length; idx++) {
            updatePidForGauge(list[idx].pid,list[idx].gauge);
        }
    }

    function removeShutdownGauge(uint8 pid) public {
        if(booster.poolInfo(pid).shutdown==true &&
        poolList[booster.poolInfo(pid).gauge].pid == pid ){
            poolList[booster.poolInfo(pid).gauge] = GaugeDetails(0x0000000000000000000000000000000000000000,0);
        } else {
            revert("gauge not shutdown or pid doesn't match");
        }
    }

}
