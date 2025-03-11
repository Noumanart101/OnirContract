// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {OnirContract} from "../src/OnirContract.sol";

contract DeployOnirContract is Script {
    function run() external {
        vm.startBroadcast();
        new OnirContract(
            0x02C5321b84100eb721916961bB586683b9ceC898,
            0xA6C465b04Bef01F524D48E2a7914D24129dE00D9
        );
        vm.stopBroadcast();
    }
}
