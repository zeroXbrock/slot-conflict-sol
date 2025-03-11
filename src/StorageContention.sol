// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StorageContentionSimulator {
    // Mapping to store an unbounded number of storage slots
    mapping(uint256 => uint256) private slots;

    // Event to log the updates
    event SlotUpdated(uint256 slot, uint256 newValue);

    // guess a value, pay a fee proportional to the how close the value is

    // Function to write to a specific slot if the current value is within the expected range
    function writeToSlot(
        uint256 slot,
        uint256 lowerBoundCurrentExpectedValue,
        uint256 upperBoundCurrentExpectedValue,
        uint256 newValue,
        uint256 payment
    ) public {
        uint256 currentValue = slots[slot];
        require(
            currentValue >= lowerBoundCurrentExpectedValue &&
                currentValue <= upperBoundCurrentExpectedValue,
            "Current value does not fall within the expected range"
        );
        slots[slot] = newValue;
        block.coinbase.transfer(payment);
        emit SlotUpdated(slot, newValue);
    }

    function writeToSlotProportional(
        uint256 slot,
        uint256 lowerBoundCurrentExpectedValue,
        uint256 upperBoundCurrentExpectedValue,
        uint256 newValue,
        uint256 payment
    ) public {
        uint256 currentValue = slots[slot];
        uint256 diff = abs(int256(currentValue) - int256(newValue));
        require(
            currentValue >= lowerBoundCurrentExpectedValue &&
                currentValue <= upperBoundCurrentExpectedValue,
            "Current value does not fall within the expected range"
        );
        slots[slot] = newValue;
        block.coinbase.transfer(payment * (1 / diff));
        emit SlotUpdated(slot, newValue);
    }

    // Function to write to multiple slots with the possibility of reverting
    function writeToMultipleSlots(
        uint256[] calldata slotsArray,
        uint256[] calldata lowerBounds,
        uint256[] calldata upperBounds,
        uint256[] calldata newValues,
        uint256[] calldata payments
    ) public {
        require(
            slotsArray.length == newValues.length,
            "Slots and values length mismatch"
        );
        require(
            slotsArray.length == lowerBounds.length,
            "Slots and lower bounds length mismatch"
        );
        require(
            slotsArray.length == upperBounds.length,
            "Slots and upper bounds length mismatch"
        );

        for (uint256 i = 0; i < slotsArray.length; i++) {
            writeToSlot(
                slotsArray[i],
                lowerBounds[i],
                upperBounds[i],
                newValues[i],
                payments[i]
            );
        }
    }

    function writeToMultipleSlotsProprtional(
        uint256[] calldata slotsArray,
        uint256[] calldata lowerBounds,
        uint256[] calldata upperBounds,
        uint256[] calldata newValues,
        uint256[] calldata payments
    ) public {
        require(
            slotsArray.length == newValues.length,
            "Slots and values length mismatch"
        );
        require(
            slotsArray.length == lowerBounds.length,
            "Slots and lower bounds length mismatch"
        );
        require(
            slotsArray.length == upperBounds.length,
            "Slots and upper bounds length mismatch"
        );

        for (uint256 i = 0; i < slotsArray.length; i++) {
            writeToSlotProportional(
                slotsArray[i],
                lowerBounds[i],
                upperBounds[i],
                newValues[i],
                payments[i]
            );
        }
    }

    // Function to read from a specific slot
    function readFromSlot(uint256 slot) public view returns (uint256) {
        return slots[slot];
    }

    function read_coinbase_write_slot(
        uint256 slot,
        uint256 topOfBlockValue,
        uint256 expectedCoinbaseValue,
        uint256 lowerBoundCurrentExpectedValue,
        uint256 upperBoundCurrentExpectedValue,
        uint256 newValue,
        uint256 payment
    ) external {
        uint256 coinbase = block.coinbase.balance;

        if (coinbase == expectedCoinbaseValue) {
            (bool sent, ) = block.coinbase.call{value: topOfBlockValue}("");
            require(sent, "Failed to send Ether");
        } else {
            writeToSlotProportional(
                slot,
                lowerBoundCurrentExpectedValue,
                upperBoundCurrentExpectedValue,
                newValue,
                payment
            );
            (
                slot,
                lowerBoundCurrentExpectedValue,
                upperBoundCurrentExpectedValue,
                newValue,
                payment
            );
        }
    }

    // Function to simulate read-modify-write operations
    function readModifyWrite(uint256 slot, uint256 modifierValue) public {
        uint256 currentValue = slots[slot];
        uint256 newValue = currentValue + modifierValue;
        slots[slot] = newValue;
        emit SlotUpdated(slot, newValue);
    }

    function abs(int256 x) public pure returns (uint256) {
        return uint256(x < 0 ? -x : x);
    }
}
