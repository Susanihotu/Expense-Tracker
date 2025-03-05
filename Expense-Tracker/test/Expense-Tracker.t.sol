// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Expense tracker.sol";
contract ExpenseTrackerTest is Test {

ExpenseTracker public expenseTracker;
address public user = address(this);
event expenseAdded (address indexed user, uint256 amount, string category, uint256 timestamp);
event BudgetUser ( address indexed user, string category, uint256 budget);
struct Expense {
uint256 amount;
string category;
uint256 timestamp;
}
    function setUp () public{
        expenseTracker= new ExpenseTracker();
    }

function testaddExpenseAmountZero() public {
    uint256 amount =0;
    string memory category = "Food";
    vm.expectRevert();
    expenseTracker.addExpense(category, amount);
}
function testAddExpense() public {
        uint256 amount = 100;
        string memory category = "Food";
        vm.expectEmit(true, true, false, true);
        emit expenseAdded(user, amount, category, block.timestamp);
        expenseTracker.addExpense( category, amount);

        
        (uint256 addedAmount, string memory addedCategory, uint256 addedTimestamp) = expenseTracker.getExpense(user, 0);
        assertEq(addedAmount, amount, "Expense amount should match");
        assertEq(addedCategory, category, "Expense category should match");
        assertTrue(addedTimestamp > 0, "Expense timestamp should be greater than zero");

        uint256 expenseCount = expenseTracker.getExpenseCount(user);
        assertEq(expenseCount, 1, "There should be exactly one expense for the user");
    }
    function testSetBudget() public {
        uint256 budgetAmount = 500;
        string memory category = "Food";

        
        vm.expectEmit(true, true, false, true);
        emit BudgetUser(user, category, budgetAmount);

        // Set a budget for the category
        expenseTracker.setBudget(category, budgetAmount);

        // Verify that the budget was set correctly
        uint256 retrievedBudget = expenseTracker.getBudget(category);
        assertEq(retrievedBudget, budgetAmount, "Budget amount should match the set value");
    }
    function testGetMonthlySpending() public {
        uint256 amount1 = 100;
        uint256 amount2 = 200;
        string memory category = "Food";

        expenseTracker.addExpense(category, amount1);
        expenseTracker.addExpense(category,amount2);

        uint256 totalSpent = expenseTracker.getMonthlySpending(category);
        assertEq(totalSpent, amount1 + amount2, "Total monthly spending should match the sum of added expenses");
    }
    function testWithinBudget() public {
        uint256 budgetAmount = 500;
        uint256 amountSpent = 300;
        string memory category = "Entertainment";
        
        expenseTracker.setBudget(category, budgetAmount);
        expenseTracker.addExpense(category, amountSpent);

        
        bool isWithin = expenseTracker.withinBudeget(category);
        assertTrue(isWithin, "Spending should be within the budget");

        
        expenseTracker.addExpense( category, amountSpent);
        
        isWithin = expenseTracker.withinBudeget(category);
        assertFalse(isWithin, "Spending should exceed the budget after adding another expense");
    }
    function testExpenseArrayLength() public {
        string memory category = "Food";
        uint256 initialLength = expenseTracker.getUserExpensesLength(user);

        // Add multiple expenses
        expenseTracker.addExpense(category, 100);
        expenseTracker.addExpense(category, 200);
        expenseTracker.addExpense(category, 300);

        // Verify that the expense array length has increased
        uint256 finalLength = expenseTracker.getUserExpensesLength(user);
        assertEq(finalLength, initialLength + 3, "The length of user expenses should increase by 3");
    }





    
}
