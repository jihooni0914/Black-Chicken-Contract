// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract TestChicken is  ERC721URIStorage, Ownable
{
    string private baseURI;
    string private defaultImage = "https://s2.coinmarketcap.com/static/img/coins/200x200/2930.png";
    uint256 private constant MAX_ATTRIBUTE_NUMBER = 7;

    struct NFTInfo
    {
        uint256 hash;
        string imageURL;

        uint8[MAX_ATTRIBUTE_NUMBER] attributes;
        // mapping(uint8 => uint8) attributes;
    }

    enum Attribute
    {
        background,
        bar,
        blade_fire,
        blade_blood,
        crossguard1,
        crossguard2,
        accessories
    }

    mapping(uint256 => NFTInfo) private _nftInfo;


    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private constant MAX_SUPPLY = 1000000000;
    uint256 private constant MIX_PRICE = 100;
    uint256 private constant MINT_PRICE = 100;
    uint256 private totalSupply = 0;


    constructor(string memory _name, string memory _simbol) ERC721(_name, _simbol)
    {
    }


    function getTotalSupply() public view returns (uint256) { return totalSupply; }

    function setBaseURI(string memory _uri) public 
    {
        baseURI = _uri;
    }


    function setTokenImage(uint256 _tokenId, string memory _imageURL) public 
    {
        require(_exists(_tokenId), "Token is not exist");

        _nftInfo[_tokenId].imageURL = _imageURL;
    }

    function getTokenImageURL(uint256 _tokenId) public view returns (string memory)
    {
        require(_exists(_tokenId), "Token is not exist");

        return _nftInfo[_tokenId].imageURL;
    }

    

    function addNFTInfo(uint256 _tokenId, uint256 _hash, string memory _imageURL) private
    {
        require(_exists(_tokenId), "not exist");


        uint256 mask = 0xff;
        uint8[MAX_ATTRIBUTE_NUMBER] memory attribtues;

        for (uint i = 0; i < MAX_ATTRIBUTE_NUMBER; i ++)
        {
            attribtues[i] = uint8(_hash >> i | mask) % 10;
        }

        _nftInfo[_tokenId] = NFTInfo(
            _hash,
            _imageURL,
            attribtues
            );
    }

    function getNFTAttribute(uint256 _tokenId, Attribute _attribute) public view returns(uint8)
    {
        return _nftInfo[_tokenId].attributes[uint256(_attribute)];
    }

    function mintNFT(address recipient, string memory _tokenURI, string memory _tokenImage) public returns(uint256)
    {
        require(totalSupply < MAX_SUPPLY, "Full supplied");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        totalSupply ++;

        _setTokenURI(newItemId, _tokenURI);
        setTokenImage(newItemId, _tokenImage);


        uint256 hash = uint256(keccak256(abi.encode(block.timestamp)));
        addNFTInfo(newItemId, hash, defaultImage);

        return newItemId;
    }

    function burnNFT(uint256 _tokenId) private
    {
        require(_exists(_tokenId), "not exist");

        delete _nftInfo[_tokenId];
        _burn(_tokenId);
    }
}