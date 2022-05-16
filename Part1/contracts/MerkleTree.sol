//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

import "hardhat/console.sol";

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 public constant treeHeight = 3;

    constructor() {
        hashes = new uint256[](2**(treeHeight + 1) - 1);

        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for(uint256 i=0; i < 8; i++) {
          hashes[i] = 0;
        }

        for(uint256 i=0; i < 14; i+=2) {
          hashParent(i);
        }

        root = hashes[hashes.length - 1];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint256 parentIndex = index;
        for(uint256 currentHeight = 0; currentHeight < treeHeight; currentHeight++) {
          parentIndex = hashParent(parentIndex);
        }
        root = hashes[hashes.length - 1];
        index += 1;
        return index;
    }

    function hashParent(uint256 _index) internal returns (uint256) {
        uint256 parentIndex = (_index / 2) + 2**treeHeight;

        if(_index % 2 == 0) {
          hashes[parentIndex] = PoseidonT3.poseidon([hashes[_index], hashes[_index + 1]]);
        } else {
          hashes[parentIndex] = PoseidonT3.poseidon([hashes[_index - 1], hashes[_index]]);
        }

        return parentIndex;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input) && input[0] == root;
    }
}
