pragma solidity ^0.7.0;
pragma abicoder v2;

contract Market{
    
    address private immutable owner;
    mapping(address => uint) goodsOwned;
    
    struct good {
        uint112 price;
        uint112 id;
        address owner;
        string name;
    }
    
    good[] public goods;
    
    constructor() {
        owner = msg.sender;
    }
    
    function sell(string memory _name, uint _price) external{
        goodsOwned[msg.sender] = ++goodsOwned[msg.sender];
        goods.push(good( uint112(_price), uint112(goods.length), msg.sender, _name));
    }
    
    function buy(uint id) external payable{
        good memory _good = goods[id];
        require(msg.value >= _good.price);
        goodsOwned[msg.sender] = ++goodsOwned[msg.sender];
        goodsOwned[_good.owner] = --goodsOwned[_good.owner];
        _good = good(_good.price, uint112(id), msg.sender, _good.name);
        goods[id] = _good;
        payable(_good.owner).transfer(msg.value);
    }
    
    function getAddressGoods(address _address) public view returns(good[] memory){
        good[] memory _goods = new good[](goodsOwned[_address]);
        for(uint112 i = 0; i < goods.length; i++){
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