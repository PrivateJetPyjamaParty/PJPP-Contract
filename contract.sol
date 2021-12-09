// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract PJPP is ERC1155, Ownable {
    bool public revealed = false;
    string private _uri;
    string fakeUrl;
    constructor(string memory url)
        ERC1155(url)
    {
        _uri = url;
    }

    function setURI(string memory newuri) public onlyOwner {
        _uri = newuri;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setFakeUrl(string memory fake)public onlyOwner{
        fakeUrl = fake;
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
    public
    onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    public
    onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function uri(uint256 tokenId) override public view returns (string memory){
    if(revealed == false) {
        return(string(abi.encodePacked(fakeUrl)));
    }
        return(string(abi.encodePacked(_uri,"/",Strings.toString(tokenId),".json")));
    }
}


// ipfs://QmYgcpefFqZQ6TUtC8bm8RXtDMyj23X8PZtVK2jvPUhqFB
// ipfs://QmY8icBeWg2iGmkj7sCa3fVbd35Uf5QTkM12zyxcPjvcsR

