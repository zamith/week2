pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var numLeaves = 2**n;
    var numNodes = (2**n+1) - 1;
    var index;

    component hashPairs[numNodes];
    for (var i = 0; i < numNodes; i++) {
        hashPairs[i] = HashPair();

        if (i < numLeaves) {
          hashPairs[i].a <== leaves[i];
          hashPairs[i].b <== leaves[i];
        } else {
          var index = (i - numLeaves);
          hashPairs[i].a <== hashPairs[index * 2].out;
          hashPairs[i].b <== hashPairs[index * 2 + 1].out;
        }
    }

    root <== hashPairs[numNodes-1].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashPairs[n];
    component muxes[n];

    signal hashedLevels[n + 1];
    hashedLevels[0] <== leaf;

    for (var i=0; i < n; i++) {
      muxes[i] = MultiMux1(2);

      muxes[i].c[0][0] <== hashedLevels[i];
      muxes[i].c[0][1] <== path_elements[i];

      muxes[i].c[1][0] <== path_elements[i];
      muxes[i].c[1][1] <== hashedLevels[i];

      muxes[i].s <== path_index[i];

      hashPairs[i] = HashPair();
      hashPairs[i].a <== muxes[i].out[0];
      hashPairs[i].b <== muxes[i].out[1];

      hashedLevels[i+1] <== hashPairs[i].out;
    }

    root <== hashedLevels[n];
}

template HashPair() {
  signal input a;
  signal input b;
  signal output out;

  component poseidon = Poseidon(2);
  poseidon.inputs[0] <== a;
  poseidon.inputs[1] <== b;

  out <== poseidon.out;
}
