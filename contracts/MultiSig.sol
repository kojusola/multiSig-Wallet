// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MultiSig {
    address[] owners;
    mapping(address => bool) ownersMapping;
    mapping(uint => mapping(address => bool)) votedMapping;

    uint minimumApprovalRequired;

    struct TransactionData {
        uint id;
        address toAddress;
        uint256 amount;
        address requestedBy;
        uint256 timeStamp;
        uint numberOfApproval;
        bool status;
    }

    TransactionData[] transactionsArray;

    constructor(address[] memory _owners, uint _minimumApprovalRequired) {
        owners = _owners;
        minimumApprovalRequired = _minimumApprovalRequired;
        for(uint i; i < _owners.length; i++) {
            address _owner = _owners[i];
            ownersMapping[_owner] = true;
        }
    }

    modifier onlyOnwers {
        require(ownersMapping[msg.sender] == true, "only the owners can call this this function");
        _;
    }


    function requestTransaction(uint _amount, address _to) external onlyOnwers returns(uint) {
        uint _id = transactionsArray.length;
        TransactionData memory transact = TransactionData(_id, _to, _amount, msg.sender, block.timestamp, 0, false);

        transactionsArray.push(transact);

        return _id;
    }

    function approveTransaction(uint _transactionId) external onlyOnwers returns(uint) {
        // transactionsArray[_tansactionId].numberOfApproval + 1;
        require(votedMapping[_transactionId][msg.sender] != true, "You already approved this transaction");
        uint _numberOfApproval =  ++transactionsArray[_transactionId].numberOfApproval;
        if(transactionsArray[_transactionId].numberOfApproval == minimumApprovalRequired ){
            transactionsArray[_transactionId].status = true;
        }
        votedMapping[_transactionId][msg.sender] = true;
        return _numberOfApproval;
    }

    function checkTransactionApproalCount(uint _transactionId) external view returns(uint) {
        return transactionsArray[_transactionId].numberOfApproval;
    }

    function checkTransactionStatus(uint _transactionId) external view returns(bool){
        return transactionsArray[_transactionId].status;
    }
}

//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]