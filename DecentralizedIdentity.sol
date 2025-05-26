// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedIdentity {
    struct Identity {
        bytes32 proofHash;    // Hash of the ZKP proof or identity commitment
        bool verified;
        address verifier;
    }

    mapping(address => Identity) public identities;
    mapping(address => bool) public authorizedVerifiers;

    address public admin;

    event IdentitySubmitted(address indexed user, bytes32 proofHash);
    event IdentityVerified(address indexed user, address indexed verifier);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Not authorized verifier");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addVerifier(address _verifier) external onlyAdmin {
        authorizedVerifiers[_verifier] = true;
        emit VerifierAdded(_verifier);
    }

    function removeVerifier(address _verifier) external onlyAdmin {
        authorizedVerifiers[_verifier] = false;
        emit VerifierRemoved(_verifier);
    }

    function submitIdentity(bytes32 _proofHash) external {
        identities[msg.sender] = Identity({
            proofHash: _proofHash,
            verified: false,
            verifier: address(0)
        });

        emit IdentitySubmitted(msg.sender, _proofHash);
    }

    function verifyIdentity(address _user) external onlyVerifier {
        require(identities[_user].proofHash != 0x0, "No identity submitted");

        identities[_user].verified = true;
        identities[_user].verifier = msg.sender;

        emit IdentityVerified(_user, msg.sender);
    }

    function isVerified(address _user) external view returns (bool) {
        return identities[_user].verified;
    }

    function getProofHash(address _user) external view returns (bytes32) {
        return identities[_user].proofHash;
    }
}
