// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Materials} from "../src/Materials.sol";
import {Assembler} from "../src/Assembler.sol";

contract DeployMaterials is Script {
    function run() public returns (Materials, Assembler) {
        vm.startBroadcast();
        Materials materials = new Materials();
        Assembler assembler = new Assembler();
        materials.setAssembler(address(assembler));
        assembler.setMaterials(address(materials));
        vm.stopBroadcast();
        return (materials, assembler);
    }
}
