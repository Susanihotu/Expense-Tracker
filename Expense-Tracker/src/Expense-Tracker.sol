// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract ExpenseTracker{
struct Expense {
uint256 amount;
string category;
uint256 timestamp;
}

mapping( address => Expense[]) public userExpense;
mapping( address => mapping (string=> uint256 ) ) public userBudjet;

event expenseAdded (address indexed user, uint256 amount, string category, uint256 timestamp);
event BudgetUser ( address indexed user, string category, uint256 budget);

function addExpense (string memory _category, uint256 _amount) public {
     require( _amount > 0, " INVALID AMOUNT");
    Expense memory newExpense = Expense ({
        amount:  _amount,
        category:  _category,
        timestamp : block.timestamp
    });
    userExpense[msg.sender].push(newExpense);
    emit expenseAdded (msg.sender, _amount, _category, block.timestamp);
}
function getUserExpensesLength(address user) public view returns (uint256) {
    return userExpense[user].length;
}

function setBudget(string memory _category, uint256 _amount) public {
    require( _amount > 0, " INVALID AMOUNT");
    userBudjet[msg.sender] [_category] = _amount;
    emit BudgetUser ( msg.sender, _category, _amount);

}

function getBudget( string memory _category) public view returns (uint256) {
    return userBudjet[msg.sender] [_category];
}
function getExpenseCount(address _user) public view returns (uint256) {
    return userExpense[_user].length;
}


function getExpense(address _user, uint256 _index) public view returns (
    uint256 amount,
    string memory category,
    uint256 timestamp
) {
    require(_index < userExpense[_user].length, "Index out of bounds");
    Expense memory expense = userExpense[_user][_index];
    return (expense.amount, expense.category, expense.timestamp);
}


function getMonthlySpending(string memory _category) public view returns (uint256) {
    uint256 totalSpent = 0;
    uint256 currentMonth = block.timestamp / 30 days;

    for (uint256 i = 0; i < userExpense[msg.sender].length; i++) {
        Expense memory expense = userExpense[msg.sender][i];
        uint256 expenseMonth = expense.timestamp / 30 days;

        if (
            keccak256(abi.encodePacked(expense.category)) == keccak256(abi.encodePacked(_category)) &&
            expenseMonth == currentMonth
        ) {
            totalSpent += expense.amount;
        }
    }
    return totalSpent;
}

function withinBudeget (string memory _category) public view returns (bool) {
    uint256 totalSpent = getMonthlySpending(_category);
        uint256 budget = userBudjet[msg.sender][_category];
        return totalSpent <= budget;
}




}