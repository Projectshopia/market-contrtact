// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.0;
pragma abicoder v2;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Shopia {
    
    uint public totalCount = 0;
    uint public availableProductsCount = 0;
    mapping(uint => Product) products;
    address private immutable owner;

    struct Product {
        uint id;
        string name;
        uint price;
        address payable owner;
        bool isPurchased;
    }

    event ProductAdded(
        uint id,
        string name,
        uint price,
        address payable owner,
        bool isPurchased
    );

    event ProductPurchased(
        uint id,
        string name,
        uint price,
        address payable owner,
        bool isPurchased
    );

    constructor() {
        owner = msg.sender;
    }

    function addProduct(string memory _name, uint _price) public {
        require(bytes(_name).length >= 2 && _price > 0);

        totalCount++;
        availableProductsCount++;
        products[totalCount] = Product(totalCount, _name, _price, msg.sender, false);

        emit ProductAdded(totalCount, _name, _price, msg.sender, false);
    }

    function buyProduct(uint _id) external payable {

        // check if value exists in the products array using the totalCount
        require(_id <= totalCount, "Product Id is invalid");

        // Fetch products from array of products
        Product memory _product = products[_id];

        require(!_product.isPurchased, "Product is no longer available");

        // Validate seller is not also the owner of the product
        require(_product.owner != msg.sender, "You cannot sell to yourself");

        // Check if buyer has sufficient fund to urchase product
        require(msg.value >= _product.price, "Insufficient funds");

        address payable _seller = _product.owner;

        _product.isPurchased = true;
        _product.owner = msg.sender;

        products[_id] = _product;

        availableProductsCount--;

        _seller.transfer(msg.value);
        
        emit ProductPurchased(_id, _product.name, _product.price, msg.sender, true);
    }
    
    function availableProducts() public view returns (Product[] memory) {
        Product[] memory listedProducts = new Product[](availableProductsCount);
        
        uint8 count = 0;

        if (availableProductsCount > 0) {
            for (uint i = 1; i <= totalCount; i++) {
                if (!products[i].isPurchased) {
                    listedProducts[count] = products[i];
                    count++;
                }
            }
        }
        
        return listedProducts;
    }
    
    
    function ownedProducts(address _address) public view returns (Product[] memory) {
        uint ownedProductsCount = 0;

        for (uint i = 1; i <= totalCount; i++) {
            if (products[i].owner == _address) {
                ownedProductsCount += 1;
            }
        }
        
        Product[] memory productsOwned = new Product[](ownedProductsCount);
        
        uint8 count = 0;

        if (ownedProductsCount > 0) {
            for (uint i = 1; i <= totalCount; i++) {
                if (products[i].owner == _address) {
                    productsOwned[count] = products[i];
                    count++;
                }
            }
        }
        
        return productsOwned;
    }
}