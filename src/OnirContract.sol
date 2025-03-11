// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract OnirContract is ReentrancyGuard, Ownable {
    // Custom errors for gas efficiency
    error OnirContract__InsufficientCompanyIncome();
    error OnirContract__IncomeMustBeGreaterThanZero();
    error OnirContract__SalaryCanOnlyBePaidOnceInMonth();
    error OnirContract__NoProfitToDistribute();
    error OnirContract__ProfitsCanOnlyBeDistributedEverySixMonths();
    error OnirContract__Unauthorized();

    // Struct to store partner details
    struct Partner {
        address wallet;
        uint256 share;
        uint256 lastProfitDistribution;
    }

    // State variables
    uint256 private constant BUDGET = 2500 ether; // Represents €2,500 in ETH, could use Chainlink in real case scenario
    uint256 private constant MONTHLY_SALARY = 1000 ether; // Represents €1,000 in ETH, could use chainlink in real case scenario
    uint256 private companyIncome;
    uint256 private lastSalaryPayment;
    uint256 private lastProfitDistribution;

    // Partners
    Partner private ceo; // Zain Jutt
    Partner private partner; // Mr. Cresta

    // Events
    event SalaryPaid(address indexed recipient, uint256 amount);
    event ProfitDistributed(address indexed recipient, uint256 amount);
    event BudgetUsed(address indexed spender, uint256 amount);

    // Constructor
    constructor(
        address _ceoWallet,
        address _partnerWallet
    ) Ownable(_ceoWallet) {
        ceo = Partner({
            wallet: _ceoWallet,
            share: 50, // 50% ownership
            lastProfitDistribution: block.timestamp
        });

        partner = Partner({
            wallet: _partnerWallet,
            share: 50, // 50% ownership
            lastProfitDistribution: block.timestamp
        });

        lastSalaryPayment = block.timestamp;
        lastProfitDistribution = block.timestamp;
    }

    // Modifier to restrict access to the CEO
    modifier onlyCEO() {
        if (msg.sender != ceo.wallet) revert OnirContract__Unauthorized();
        _;
    }

    // Modifier to restrict access to the partner
    modifier onlyPartner() {
        if (msg.sender != partner.wallet) revert OnirContract__Unauthorized();
        _;
    }

    // Function to add company income
    function addIncome(uint256 amount) external payable onlyOwner {
        if (amount <= 0) {
            revert OnirContract__IncomeMustBeGreaterThanZero();
        }
        companyIncome += amount;
    }

    // Function to pay the CEO's monthly salary
    function paySalary() external nonReentrant onlyCEO {
        if (companyIncome < MONTHLY_SALARY)
            revert OnirContract__InsufficientCompanyIncome();
        if (block.timestamp <= lastSalaryPayment + 30 days)
            revert OnirContract__SalaryCanOnlyBePaidOnceInMonth();

        companyIncome -= MONTHLY_SALARY;

        emit SalaryPaid(ceo.wallet, MONTHLY_SALARY);

        payable(ceo.wallet).transfer(MONTHLY_SALARY);
        lastSalaryPayment = block.timestamp;
    }

    // Function to distribute profits every six months
    function distributeProfits() external nonReentrant onlyOwner {
        if (companyIncome == 0) revert OnirContract__NoProfitToDistribute();
        if (block.timestamp <= lastProfitDistribution + 180 days)
            revert OnirContract__ProfitsCanOnlyBeDistributedEverySixMonths();

        uint256 profit = companyIncome;
        uint256 ceoShare = (profit * ceo.share) / 100;
        uint256 partnerShare = (profit * partner.share) / 100;

        companyIncome = 0;
        emit ProfitDistributed(ceo.wallet, ceoShare);
        emit ProfitDistributed(partner.wallet, partnerShare);

        payable(ceo.wallet).transfer(ceoShare);
        payable(partner.wallet).transfer(partnerShare);
        lastProfitDistribution = block.timestamp;
    }

    // Function to use the budget (can be called by either CEO or partner)
    function useBudget(uint256 amount) external nonReentrant {
        if (msg.sender != ceo.wallet || msg.sender != partner.wallet)
            revert OnirContract__Unauthorized();
        if (amount > BUDGET) revert OnirContract__Unauthorized();

        emit BudgetUsed(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    // Fallback function to receive ETH
    receive() external payable {
        companyIncome += msg.value;
    }
}
