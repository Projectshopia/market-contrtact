// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;
pragma abicoder v2;

contract Market{
    
    address private immutable owner;
    mapping(address => uint) goodsOwned;
    
    event goodAdded(
        uint price,
        uint id,
        address owner,
        string name
    );

    event goodPurchased(
        uint price,
        uint id,
        address owner,
        string name
    );
    
    struct good {
        uint price;
        uint id;
        address owner;
        string name;
    }
    
    good[] goods;
    
    constructor() {
        owner = msg.sender;
    }
    
    function addProduct(string memory _name, uint _price) external{
        goodsOwned[msg.sender] = ++goodsOwned[msg.sender];
        goods.push(good(uint(_price), uint(goods.length), msg.sender, _name));
        emit goodAdded(uint(_price), uint(goods.length), msg.sender, _name);
    }
    
    function buyProduct(uint id) external payable{
        good memory _good = goods[id];
        require(msg.value >= _good.price, "Insuffient funds");
        
        // Validate seller is not also the owner of the product
        require(_good.owner != msg.sender, "You cannot sell to yourself");
        
        goodsOwned[msg.sender] = ++goodsOwned[msg.sender];
        goodsOwned[_good.owner] = --goodsOwned[_good.owner];
        _good = good(uint(_good.price), uint(id), msg.sender, _good.name);
        goods[id] = _good;
        payable(_good.owner).transfer(msg.value);
        emit goodPurchased(uint(_good.price), uint(id), msg.sender, _good.name);
    }
    
    function getAddressGoods(address _address) public view returns(good[] memory){
        good[] memory _goods = new good[](goodsOwned[_address]);
        for(uint i = 0; i < goods.length; i++){
            if(goods[i].owner == _address){
                _goods[_goods.length-1] = goods[i];
            }
        }
        return _goods;
    }
    
    function getAllGoods() public view returns (good[] memory){
        return goods;
    }
} 