// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Custom error to indicate that the new seed is too short
error SeedTooShort();

/// @title Coinflip 10 in a Row
/// @notice This contract implements a simple coin flip game where the user must correctly guess 10 coin flips in a row.
/// The coin flips are generated pseudo-randomly by hashing characters from a seed and the current block timestamp.
contract Coinflip is Ownable {
    
    // The seed string used to generate pseudo-random coin flips.
    // In a real-world scenario, this should be updated frequently to maintain unpredictability.
    string public seed;

    /// @notice The constructor sets the initial seed to a predefined value.
    constructor() Ownable(msg.sender) {
        // Setting the seed to a recommended initial string.
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    /// @notice Checks user input against contract generated coin flips.
    /// @param Guesses A fixed array of 10 elements representing the user's guesses (each guess is either 1 for heads or 0 for tails).
    /// @return true if the user correctly guesses all 10 coin flips, false otherwise.
    function userInput(uint8[10] calldata Guesses) external view returns (bool) {
        // Retrieve the generated coin flips using the helper function.
        uint8[10] memory flips = getFlips();

        // Compare each element of the user's guesses with the corresponding generated flip.
        // If any guess does not match, return false immediately.
        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != flips[i]) {
                return false;
            }
        }
        // If all 10 guesses match the generated coin flips, return true.
        return true;
    }

    /// @notice Allows the owner of the contract to update the seed to a new value.
    /// @param NewSeed A string representing the new seed.
    function seedRotation(string memory NewSeed) public onlyOwner {
        // Cast the new seed string to a bytes array so we can get its length.
        bytes memory newSeedBytes = bytes(NewSeed);
        uint seedlength = newSeedBytes.length; // Get the length (number of characters) of the new seed.

        // If the new seed is less than 10 characters, revert with a SeedTooShort error.
        if (seedlength < 10) {
            revert SeedTooShort();
        }
        
        // Set the contract's seed to the new seed.
        seed = NewSeed;
    }

    // -------------------- Helper Functions -------------------- //

    /// @notice Generates 10 pseudo-random coin flips using characters from the seed.
    /// @return A fixed array of 10 elements of type uint8, where each element is either 1 (heads) or 0 (tails).
    function getFlips() public view returns (uint8[10] memory) {
        // Cast the seed string into a bytes array so we can access individual characters.
        bytes memory seedBytes = bytes(seed);
        uint seedlength = seedBytes.length; // Determine the length of the seed.

        // Initialize an empty fixed array to store the results (10 coin flips).
        uint8[10] memory results;

        // Calculate the interval at which to pick characters from the seed.
        // This evenly divides the seed into 10 segments.
        uint interval = seedlength / 10;

        // Loop 10 times, once for each coin flip.
        // We use 'i' to determine which segment of the seed to sample.
        for (uint i = 0; i < 10; i++) {
            // Pick a character from the seed based on the interval.
            // Combine the character with the block timestamp to generate pseudo-randomness.
            uint randomNum = uint(keccak256(abi.encode(seedBytes[i * interval], block.timestamp)));
            
            // If the random number is even, record the coin flip as 1 (heads).
            // Otherwise, record it as 0 (tails).
            if (randomNum % 2 == 0) {
                results[i] = 1;
            } else {
                results[i] = 0;
            }
        }

        // Return the fixed array containing the 10 generated coin flips.
        return results;
    }
}
