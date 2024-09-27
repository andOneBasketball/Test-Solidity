// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
contract StructCase{
    struct Car {
        bytes model;
        uint year;
        address owner;
    }
    uint public id = 0;
    mapping(uint => Car) public carsByOwner;
    function examples(bytes memory _model, uint _year, address _owner) external {
        carsByOwner[id] = Car(_model, _year, _owner);
        id++;
    }

    function getCar(uint _id) public view returns(bool) {
        // carsByOwner[_id] == Car("", 0, address(0))  error 不允许如此比较
        if (carsByOwner[_id].owner == address(0)) {
            return false;
        } else {
            return true;
        }
    }
}