// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PJPP is ERC721Enumerable, Ownable {
  using Strings for uint256;
  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.09 ether;
  uint256 public maxSupply = 9999;
  uint256 public maxLimitWhitelist = 15;
  uint256 public maxLimitNonWhitelist = 10;
  bool public paused = false;
  bool public revealed = false;
  bool public onlyWhiteList = true;
  string public notRevealedUri;
  mapping(address => bool) public whitelisted;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function mint(address _to, uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
        
        uint256 minted = balanceOf(_to);
        if(whitelisted[_to] == true) {
            require(maxLimitWhitelist >= minted+_mintAmount, "cannot mint more than limit");
        }else{
            require(onlyWhiteList==false, "only whitelist addresses can mint");
            require(maxLimitNonWhitelist >= minted+_mintAmount, "cannot mint more than limit");
        }
        require(msg.value == cost * _mintAmount, "pay price of nft"); 
    }
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, supply + i);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  function reveal() public onlyOwner {
      revealed = true;
  }

  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setmaxLimitWhitelist(uint256 _limit) public onlyOwner {
    maxLimitWhitelist = _limit;
  }

  function setmaxLimitNonWhitelist(uint256 _limit) public onlyOwner {
    maxLimitNonWhitelist = _limit;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function setOnlyWhitelist(bool _state) public onlyOwner {
    onlyWhiteList = _state;
  }
 
 function whitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = true;
  }
 
  function removeWhitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = false;
  }

  function withdraw() payable public onlyOwner{
    uint amount = address(this).balance;
    require(amount>0, "Ether balance is 0 in contract");
    payable(address(owner())).transfer(amount);
  }
}