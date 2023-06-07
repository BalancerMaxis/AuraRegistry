// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./../interfaces/IMainnetGaugeFactory.sol";
import "./../interfaces/IMainnetGauge.sol";
import "./../interfaces/IGaugeController.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./../interfaces/IBooster.sol";



/**
 * @title Aura Registry
 * @author mike b
 * @notice registry for aura booster to get pid by gauge
 * @notice
 * see https://docs.chain.link/chainlink-automation/utility-contracts/
 */
contract gaugeRegistry {

    IBooster booster = IBooster(0xA57b8d98dAE62B26Ec3bcC4a365338157060B234);


    struct gaugeDetails {
        address lpToken;
        uint8 pid;
    }

    struct needUpdate {
        address gauge;
        uint8 pid;
    }

    mapping(address => gaugeDetails) public poolList;
    address[] public gaugeList;

    //    function getPoolInfo(uint8 pid) internal returns (gaugeDetails memory){
    //        return gaugeDetails(booster.poolInfo(pid).lptoken,booster.poolInfo(pid).gauge;
    //    }
    //
    function getLPFromPid(uint8 pid) public view returns (address){
        return (booster.poolInfo(pid).lptoken);
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
        poolList[booster.poolInfo(pid).gauge] = gaugeDetails(booster.poolInfo(pid).lptoken, pid);
        gaugeList.push(booster.poolInfo(pid).gauge);
    }

    function updatePidForGauge(uint8 pid, address gauge) public {
        if(poolList[booster.poolInfo(pid).gauge].pid == 0) {
            revert("gauge not initiated, use addGauge");
        }
        // check: supplied pid is greater than current stored pid for gauge
        // && the supplied gauge matches gauge derived from the stored pid
        // && check that the gauge of the new pid matches the gauge of the old pid
        // probably don't need second check since we gauge is directly returned from booster.poolInfo in addpool
        if(pid > poolList[gauge].pid &&
        gauge == booster.poolInfo(poolList[gauge].pid).gauge &&
        booster.poolInfo(pid).gauge == booster.poolInfo(poolList[gauge].pid).gauge
        ) {
            poolList[gauge] = gaugeDetails(booster.poolInfo(pid).lptoken, pid );
        }
    }

    // view function to iterate through all pids and see if the derived gauge is stored in poolList
    // then check if the poolList[gauge] needs its pid updated to a higher value
    function validateList(uint8 lowerBound, uint8 upperBound) public view returns (needUpdate[] memory) {

        needUpdate[] memory badGauges = new needUpdate[](upperBound - lowerBound);
        uint256 counter = 0;

        for (uint8 idx = lowerBound; idx < upperBound; idx++) {
            // check if idx is higher than stored pid in poolList(gauge)
            if (idx > poolList[booster.poolInfo(idx).gauge].pid &&
            poolList[booster.poolInfo(idx).gauge].pid != 0)
            {
                needUpdate memory test = needUpdate(booster.poolInfo(idx).gauge, idx);
                badGauges[counter] = test;
                counter++;
            }
        }
        assembly {
            mstore(badGauges, counter)
        }

        return badGauges;
    }

}
