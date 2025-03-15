// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721Token {
  string public name;
  string public symbol;
  uint256 public totalSupply;
  uint256 public constant MAX_SUPPLY = 100000;

  mapping(uint256 => address) private owners;
  mapping(address => uint256) private balances;
  mapping(uint256 => address) private tokenApprovals; // tokenid - account
  mapping(address => mapping(address => bool)) private operatorApprovals; // owner, operator, approved

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  constructor(string memory _name, string memory _symbol) {
    name = _name;
    symbol = _symbol;
  }

  function ownerOf(uint256 tokenId) public view returns (address) {
    address owner = owners[tokenId];
    require(owner != address(0), 'Token does not exist');
    return owner;
  }

  function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(owners[tokenId] != address(0), 'Token does not exist');
    return string(abi.encodePacked('https://metadata.example/', convertUintToStr(tokenId)));
  }

  function mint() public {
    require(totalSupply + 1 <= MAX_SUPPLY, 'MAX_SUPPLY exceeded');
    uint256 tokenId = totalSupply + 1;
    owners[tokenId] = msg.sender;
    balances[msg.sender] += 1;
    totalSupply += 1;
    emit Transfer(address(0), msg.sender, tokenId);
  }

  modifier onlyTokenOwner(uint256 tokenId) {
    require(ownerOf(tokenId) == msg.sender, 'Not the token owner');
    _;
  }

  function approve(address to, uint256 tokenId) public onlyTokenOwner(tokenId) {
    tokenApprovals[tokenId] = to;
    emit Approval(msg.sender, to, tokenId);
  }

  function setApprovalForAll(address operator, bool approved) public {
    operatorApprovals[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function getApproved(uint256 tokenId) view public returns (address) {
    return tokenApprovals[tokenId];
  }

  function isApprovedForAll(address owner, address operator) view public returns (bool) {
    return operatorApprovals[owner][operator];
  }

  function transferFrom(address from, address to, uint256 tokenId) public {
    require(ownerOf(tokenId) == from, 'Not token owner');
    require(to != address(0), 'Invalid recipient');
    require(msg.sender == from || tokenApprovals[tokenId] == msg.sender || operatorApprovals[from][msg.sender], 'Not approved');

    balances[from] -= 1;
    balances[to] += 1;
    owners[tokenId] = to;
    delete tokenApprovals[tokenId];

    emit Transfer(from, to, tokenId);
  }

  function convertUintToStr(uint256 _i) internal pure returns (string memory) { // func convert uint to str 
    if (_i == 0) {
        return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0) {
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    while (_i != 0) {
        length--;
        bstr[length] = bytes1(uint8(48 + _i % 10)); // Convert to ASCII
        _i /= 10;
    }
    return string(bstr);
  }
}
