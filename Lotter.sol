// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

contract Lottery{
    //entities participating
    //participant , manager , winner
    address public manager;
    //dyanamic array payable to transfer eth
    address payable[] public players;
    address payable public winner;

    mapping(address => uint) public winnings;

    constructor(){
        //during deployment 
        //constructor function will run
        manager=msg.sender;
    }

    function participate() public payable{
        //player will transfer some eth
        require(msg.sender != manager, "Manager cannot participate");
        require(msg.value==1 ether, "Please pay 1 ether only");
        players.push(payable(msg.sender));

    }

    function getBalance() public view returns(uint){
        require(manager==msg.sender,"Your are not the managaer");
        return address(this).balance;
    }

    function random() internal view returns(uint){
        //generating a random function (this is beginner level)
        //actual use oracle
        return uint(keccak256(abi.encodePacked(block.prevrandao,block.timestamp,players.length)));
    }

    function pickWinner() public{
        require(manager==msg.sender,"You are not the manager");
        require(players.length>=3,"Players are less than 3");
        uint r=random();
        uint index=r%players.length;
        winner=players[index];
        winnings[winner]+=address(this).balance;
        //reinitialise players 
        players=new address payable[](0);
    }

    function withdraw() public{
        uint amount=winnings[msg.sender];
        require(amount>0,"No winnings");
        //to prevent re entrency attack
        winnings[msg.sender]=0;
        
        (bool success,)= msg.sender.call{value:amount}("");
        //if it fails the transaction is rolled back completely
        //atomicity -> Either everything happens or nothing happens.
        require(success,"Withdraw failed");
    }
}