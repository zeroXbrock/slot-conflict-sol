// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StorageContentionSimulator} from "../src/StorageContention.sol";

contract ConflictTest is Test {
    StorageContentionSimulator public simulator;

    function setUp() public {
        simulator = new StorageContentionSimulator();
        vm.coinbase(address(0x42));
        vm.deal(address(this), 10 ether);
        vm.deal(address(simulator), 10 ether);
    }

    function test_SetSlot() public {
        simulator.writeToSlot(0, 0, 1000, 420, 1 ether / 100000);
        assertEq(simulator.readFromSlot(0), 420);
    }
}
