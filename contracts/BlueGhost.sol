// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


import "@openzeppelin/contracts/access/Ownable.sol";

import "erc721a/contracts/ERC721A.sol";

import './royalties/ContractRoyalties.sol';

contract BlueGhost is ERC721A, Ownable, ERC2981ContractRoyalties {

    //Interface for royalties
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    
    //Boolean to control public sale
    bool private publicSaleIsOpen = false;

    //comparisons are strictly less than for gas efficiency.
    uint256 numberOfTokensMinted;
    uint256 public constant MAX_SUPPLY = 10001;

    
    uint256 public constant PRICE = 0.1 ether;

    uint256 public constant MAX_PER_MINT = 11; //10
    uint256 public constant MAX_PER_WALLET = 11; //10

    uint96 public constant ROYALTIES_POINTS = 500; //5%

    string public baseTokenURI;

    event NFTMinted(uint256, uint256, address);

    //amount of mints that each address has executed.
    mapping(address => uint256) public mintsPerAddress;

    constructor(string memory baseURI) ERC721A("NFTContract", "NFT") {
        baseTokenURI = baseURI;
        setRoyalties(owner(), ROYALTIES_POINTS);
        
    }

    //ensure that modified function cannot be called by another contract
    modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract");
    _;
  }

    function _baseURI() internal view override returns (string memory) {
       return baseTokenURI;
    }
    
    /// @dev changes BaseURI and set it to the true URI for collection
    /// @param revealedTokenURI new token URI. Format required ipfs://CID/
    function reveal(string memory revealedTokenURI) public onlyOwner {
        baseTokenURI = revealedTokenURI;
    }

    function openPublicSale() external onlyOwner {
        require(publicSaleIsOpen == false, 'Sale is already Open!');
        publicSaleIsOpen = true;
    }

    ///@dev returns current tokenId. There is no burn function so it can be assumed to be sequential
    function tokenId() external view returns(uint256) {
        if (numberOfTokensMinted == 0) {
            return 0;
        } else {
            uint currentId = numberOfTokensMinted - 1;
            return currentId;
        }
    }

    /// @dev mint @param _number of NFTs in one batch.
    function mintNFTs(uint256 _number) public callerIsUser payable {
        uint256 totalMinted = numberOfTokensMinted;

        require(publicSaleIsOpen == true, "Public sale is not Open");
        require(totalMinted + _number < MAX_SUPPLY, "Not enough NFTs!");
        require(mintsPerAddress[msg.sender] + _number < MAX_PER_WALLET, "Cannot mint more than 10 NFTs per wallet");
        require(_number > 0 && _number < MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(msg.value == PRICE * _number , "Not enough/too much ether sent");
        
        mintsPerAddress[msg.sender] += _number;

        _safeMint(msg.sender, _number);
        numberOfTokensMinted += _number;

        emit NFTMinted(_number, this.tokenId(), msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @dev Sets token royalties
    /// @param recipient recipient of the royalties
    /// @param value percentage (using 2 decimals - 10000 = 100, 0 = 0)
    function setRoyalties(address recipient, uint256 value) public {
        _setRoyalties(recipient, value);
    }

    /// @dev retrieve all the funds obtained during minting
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        require(balance > 0, "No funds left to withdraw");

        (bool sent, ) = payable(owner()).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    /// @dev reverts transaction if someone accidentally send ETH to the contract 
    receive() payable external {
        revert();
    }
    
}
    
