pragma solidity ^0.4.23;

contract Bank {
	// 此合約的擁有者
    address private owner;

	// 儲存所有會員的餘額
    mapping (address => uint256) private balance;
    mapping (address => uint256) private principal;
    mapping (address => uint256) private numOfPeriod;

	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event CDEvent(address indexed from, uint256 value, uint256 period, uint256 timestamp);
    event terminateFullCDEvent(address indexed from, uint256 value, uint256 timestamp);
    event terminateEarlyCDEvent(address indexed from, uint256 value, uint256 timestamp);
    
    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }
    
	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        emit DepositEvent(msg.sender, msg.value, now);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        emit WithdrawEvent(msg.sender, etherValue, now);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        emit TransferEvent(msg.sender, to, etherValue, now);
    }
    
    //定存購買
    function CD(uint256 _period) public payable{
        principal[msg.sender] += msg.value;
        numOfPeriod[msg.sender] += _period;
        require(numOfPeriod[msg.sender] <= 12 && numOfPeriod[msg.sender] >=0, "期數最多12期，最少0期!");
        emit CDEvent(msg.sender, msg.value, _period, now);
    }
    //定存期滿
    function terminateFullCD() public payable{
        uint256 weiValue = principal[msg.sender];
        
        msg.sender.transfer(weiValue+weiValue*numOfPeriod[msg.sender]*1/100);
        
        emit terminateFullCDEvent(msg.sender,weiValue+weiValue*numOfPeriod[msg.sender]*1/100, now);
        principal[msg.sender] = 0;
        numOfPeriod[msg.sender] = 0;
    }
    //定存解約
    function terminateEarlyCD(uint256 completedPeriod) public payable{
        uint256 weiValue = principal[msg.sender];
        require(completedPeriod <=  numOfPeriod[msg.sender], "期數超過購買定存之期數");
        require(completedPeriod <= 12 && completedPeriod > =0, "期數最多12期，最少0期!");
        msg.sender.transfer(weiValue+weiValue*completedPeriod*1/100);
        
        emit terminateEarlyCDEvent(msg.sender,weiValue+weiValue*releasetime*1/100, now);
        principal[msg.sender] = 0;
        numOfPeriod[msg.sender] = 0;
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }
}