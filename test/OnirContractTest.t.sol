// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/OnirContract.sol";

contract OnirContractTest is Test {
    OnirContract private onirContract;
    address private owner = makeAddr("owner");
    address private ceo = makeAddr("ceo");
    address private partner = makeAddr("partner");
    address private stranger = makeAddr("stranger");

    // Constants
    uint256 private constant BUDGET = 2500 ether;
    uint256 private constant MONTHLY_SALARY = 1000 ether;

    // Setup function
    function setUp() public {
        // Deploy the contract with the test contract as the owner
        onirContract = new OnirContract(ceo, partner);

        // Transfer ownership to the test contract
        vm.prank(ceo); // The CEO is the initial owner
        onirContract.transferOwnership(owner);

        // Fund the test contract with ETH
        vm.deal(owner, 10000 ether); // Give the test contract 10,000 ETH
        vm.deal(ceo, 10000 ether); // Fund the CEO's address
        vm.deal(partner, 10000 ether); // Fund the partner's address
        vm.deal(stranger, 10000 ether); // Fund the stranger's address
    }

    // Test adding income
    function testAddIncome() public {
        uint256 amount = 1000 ether;

        // Add income as the owner
        vm.prank(owner);
        onirContract.addIncome(amount);

        // Check company income
        assertEq(address(onirContract).balance, amount);
    }

    // Test paying salary as CEO
    function testPaySalary() public {
        uint256 initialIncome = 2000 ether;

        // Add income
        vm.prank(owner);
        onirContract.addIncome(initialIncome);

        // Reset the block timestamp to 0
        vm.warp(0);

        // Simulate the passage of 30 days
        vm.warp(30 days);

        // Pay salary as CEO
        vm.prank(ceo);
        onirContract.paySalary();

        // Check CEO's balance
        assertEq(ceo.balance, MONTHLY_SALARY);
        assertEq(address(onirContract).balance, initialIncome - MONTHLY_SALARY);
    }

    //     // Test paying salary without sufficient income (should fail)
    //     function testPaySalaryWithoutIncome() public {
    //         vm.prank(ceo);
    //         vm.expectRevert(
    //             OnirContract.OnirContract__InsufficientCompanyIncome.selector
    //         );
    //         onirContract.paySalary();
    //     }

    //     // Test paying salary before 30 days (should fail)
    //     function testPaySalaryBefore30Days() public {
    //         uint256 initialIncome = 2000 ether;

    //         // Add income
    //         vm.prank(owner);
    //         onirContract.addIncome{value: initialIncome}();

    //         // Pay salary as CEO
    //         vm.prank(ceo);
    //         onirContract.paySalary();

    //         // Attempt to pay salary again before 30 days
    //         vm.prank(ceo);
    //         vm.expectRevert(
    //             OnirContract.OnirContract__SalaryCanOnlyBePaidOnceInMonth.selector
    //         );
    //         onirContract.paySalary();
    //     }

    //     // Test distributing profits
    //     function testDistributeProfits() public {
    //         uint256 initialIncome = 2000 ether;

    //         // Add income
    //         vm.prank(owner);
    //         onirContract.addIncome{value: initialIncome}();

    //         // Distribute profits as owner
    //         vm.prank(owner);
    //         onirContract.distributeProfits();

    //         // Check balances
    //         uint256 ceoShare = (initialIncome * 50) / 100;
    //         uint256 partnerShare = (initialIncome * 50) / 100;

    //         assertEq(ceo.balance, ceoShare);
    //         assertEq(partner.balance, partnerShare);
    //         assertEq(address(onirContract).balance, 0);
    //     }

    //     // Test distributing profits without income (should fail)
    //     function testDistributeProfitsWithoutIncome() public {
    //         vm.prank(owner);
    //         vm.expectRevert(
    //             OnirContract.OnirContract__NoProfitsToDistribute.selector
    //         );
    //         onirContract.distributeProfits();
    //     }

    //     // Test distributing profits before 180 days (should fail)
    //     function testDistributeProfitsBefore180Days() public {
    //         uint256 initialIncome = 2000 ether;

    //         // Add income
    //         vm.prank(owner);
    //         onirContract.addIncome{value: initialIncome}();

    //         // Distribute profits as owner
    //         vm.prank(owner);
    //         onirContract.distributeProfits();

    //         // Attempt to distribute profits again before 180 days
    //         vm.prank(owner);
    //         vm.expectRevert(
    //             OnirContract
    //                 .OnirContract__ProfitsCanOnlyBeDistributedEverySixMonths
    //                 .selector
    //         );
    //         onirContract.distributeProfits();
    //     }

    //     // Test using budget as CEO
    //     function testUseBudgetAsCEO() public {
    //         uint256 amount = 1000 ether;

    //         // Use budget as CEO
    //         vm.prank(ceo);
    //         onirContract.useBudget(amount);

    //         // Check CEO's balance
    //         assertEq(ceo.balance, amount);
    //     }

    //     // Test using budget as partner
    //     function testUseBudgetAsPartner() public {
    //         uint256 amount = 1000 ether;

    //         // Use budget as partner
    //         vm.prank(partner);
    //         onirContract.useBudget(amount);

    //         // Check partner's balance
    //         assertEq(partner.balance, amount);
    //     }

    //     // Test using budget as stranger (should fail)
    //     function testUseBudgetAsStranger() public {
    //         uint256 amount = 1000 ether;

    //         // Attempt to use budget as stranger
    //         vm.prank(stranger);
    //         vm.expectRevert("Only CEO or partner can use the budget");
    //         onirContract.useBudget(amount);
    //     }

    //     // Test using budget exceeding limit (should fail)
    //     function testUseBudgetExceedingLimit() public {
    //         uint256 amount = BUDGET + 1 ether;

    //         // Attempt to use budget exceeding limit
    //         vm.prank(ceo);
    //         vm.expectRevert("Amount exceeds budget");
    //         onirContract.useBudget(amount);
    //     }

    //     // Test receiving ETH via fallback
    //     function testReceiveETH() public {
    //         uint256 amount = 1000 ether;

    //         // Send ETH to the contract
    //         (bool success, ) = address(onirContract).call{value: amount}("");
    //         require(success, "ETH transfer failed");

    //         // Check company income
    //         assertEq(address(onirContract).balance, amount);
    //     }
}
