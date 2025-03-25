// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol"; 
import "@openzeppelin/contracts/utils/Counters.sol"; 
import "@openzeppelin/contracts/utils/Strings.sol"; 

// Using Arbitrum Layer2 Chain 
contract CertificateDAO is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    struct Certificate {
        address recipient;   // The address of the certificate recipient.
        string course;       // The name of the course for which the certificate is issued.
        address issuer;      // The address of the issuer (person or entity issuing the certificate).
        uint256 issueDate;   // The timestamp of when the certificate was issued.
    }
    
    // A counter to generate unique token IDs for each certificate.
    Counters.Counter private _tokenIdCounter;

    // A mapping from token IDs to Certificate struct, storing the details of each certificate.
    mapping(uint256 => Certificate) public certificates; 

    // A mapping to keep track of approved issuers who can issue certificates. 
    mapping(address => bool) public approvedIssuers; 

    // Event emitted when a certificate is issued. It logs the token ID, recipient address, course name, and issuer address.
    event CertificateIssued(uint256 tokenId, address recipient, string course, address issuer);

    // Event emitted when an issuer is approved to issue certificates.
    event IssuerApproved(address issuer);

    // Event emitted when an issuer's approval is revoked.
    event IssuerRevoked(address issuer);
    
    // The constructor initializes the contract with the name and symbol for the ERC721 token. It also inherits from Ownable, granting ownership privileges.
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable() {}
    
    // A modifier to ensure only approved issuers can perform certain actions (issue certificates).
    modifier onlyApprovedIssuer() {
        require(approvedIssuers[msg.sender], "Not an approved issuer");
        _;
    }
    
    // Allows the contract owner to approve an issuer. Emits an IssuerApproved event when successful.
    function approveIssuer(address _issuer) public onlyOwner {
        approvedIssuers[_issuer] = true;
        emit IssuerApproved(_issuer);
    }
    

    // Allows the contract owner to revoke an issuer’s approval. Emits an IssuerRevoked event when successful.    
    function revokeIssuer(address _issuer) public onlyOwner {
        approvedIssuers[_issuer] = false;
        emit IssuerRevoked(_issuer);
    }
    
    // Issues a certificate to the recipient. Generates a unique token ID using the counter, increments the counter, and mints an NFT for the recipient.
    function issueCertificate(address recipient, string memory course) public onlyApprovedIssuer {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(recipient, tokenId);

        // Stores the details of the certificate in the `certificates` mapping.
        certificates[tokenId] = Certificate({
            recipient: recipient,
            course: course,
            issuer: msg.sender,
            issueDate: block.timestamp
        });

        // Emits a CertificateIssued event to notify that a certificate has been successfully issued.
        emit CertificateIssued(tokenId, recipient, course, msg.sender);
    }
    
    // Checks if the certificate with the provided tokenId exists. If not, it throws an error.
    function verifyCertificate(uint256 tokenId) public view returns (Certificate memory) {
        require(_exists(tokenId), "Certificate does not exist");
        // Returns the certificate details for the provided tokenId.
        return certificates[tokenId];
    }
}