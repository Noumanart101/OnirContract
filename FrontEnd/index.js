import { ethers } from "./ethers-6.7.esm.min.js"
import { abi, contractAddress } from "./constants.js"

// Contract ABI (Replace with your compiled contract ABI)
const contractABI = [
  // Add your contract ABI here
];

// Contract Address (Replace with your deployed contract address)
const contractAddress = "0xYourContractAddress";

// Connect to Ethereum provider (MetaMask)
let provider;
let signer;
let contract;

// Connect Wallet
document.getElementById("connectWallet").addEventListener("click", async () => {
  if (window.ethereum) {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    contract = new ethers.Contract(contractAddress, contractABI, signer);

    const address = await signer.getAddress();
    document.getElementById("walletAddress").innerText = `Connected: ${address}`;

    // Load contract state
    loadContractState();
  } else {
    alert("Please install MetaMask!");
  }
});

// Add Income
document.getElementById("addIncome").addEventListener("click", async () => {
  const amount = document.getElementById("incomeAmount").value;
  if (!amount || isNaN(amount)) {
    alert("Please enter a valid ETH amount.");
    return;
  }

  try {
    const tx = await contract.addIncome({ value: ethers.utils.parseEther(amount) });
    await tx.wait();
    alert("Income added successfully!");
    loadContractState();
  } catch (error) {
    console.error("Error adding income:", error);
    alert("Failed to add income.");
  }
});

// Pay Salary
document.getElementById("paySalary").addEventListener("click", async () => {
  try {
    const tx = await contract.paySalary();
    await tx.wait();
    alert("Salary paid successfully!");
    loadContractState();
  } catch (error) {
    console.error("Error paying salary:", error);
    alert("Failed to pay salary.");
  }
});

// Distribute Profits
document.getElementById("distributeProfits").addEventListener("click", async () => {
  try {
    const tx = await contract.distributeProfits();
    await tx.wait();
    alert("Profits distributed successfully!");
    loadContractState();
  } catch (error) {
    console.error("Error distributing profits:", error);
    alert("Failed to distribute profits.");
  }
});

// Use Budget
document.getElementById("useBudget").addEventListener("click", async () => {
  const amount = document.getElementById("budgetAmount").value;
  if (!amount || isNaN(amount)) {
    alert("Please enter a valid ETH amount.");
    return;
  }

  try {
    const tx = await contract.useBudget(ethers.utils.parseEther(amount));
    await tx.wait();
    alert("Budget used successfully!");
    loadContractState();
  } catch (error) {
    console.error("Error using budget:", error);
    alert("Failed to use budget.");
  }
});

// Load Contract State
async function loadContractState() {
  if (!contract) return;

  const companyIncome = await contract.companyIncome();
  const lastSalaryPayment = await contract.lastSalaryPayment();
  const lastProfitDistribution = await contract.lastProfitDistribution();

  document.getElementById("companyIncome").innerText = ethers.utils.formatEther(companyIncome);
  document.getElementById("lastSalaryPayment").innerText = new Date(lastSalaryPayment * 1000).toLocaleString();
  document.getElementById("lastProfitDistribution").innerText = new Date(lastProfitDistribution * 1000).toLocaleString();
}