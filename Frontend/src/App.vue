<script setup>
import { ref, provide, onMounted } from 'vue';
import { ethers } from 'ethers';
import CoinFlipABI from './abis/CoinFlipABI.json';

const contractRead = ref(null);
const contractWrite = ref(null);
const userAddress = ref(null);
const balance = ref(0);

async function connectMetaMask() {
  if (window.ethereum && window.ethereum.isMetaMask) {
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();

      userAddress.value = await signer.getAddress();
      const unformattedBalance = await provider.getBalance(userAddress.value);
      balance.value = ethers.formatEther(unformattedBalance);

      contractRead.value = new ethers.Contract(
        import.meta.env.VITE_DEPLOYED_CONTRACT_ADDRESS,
        CoinFlipABI,
        provider
      );

      contractWrite.value = new ethers.Contract(
        import.meta.env.VITE_DEPLOYED_CONTRACT_ADDRESS,
        CoinFlipABI,
        signer
      );

    } catch (error) {
      alert('The following error occurred: ' + error.message);
    }
  } else {
    alert('MetaMask is not installed');
  }
};

async function updateBalance() {
  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const unformattedBalance = await provider.getBalance(userAddress.value);
    balance.value = ethers.formatEther(unformattedBalance);
  } catch (error) {
    alert('Error updating balance: ' + error);
  }
}

onMounted(() => {
  connectMetaMask();
});

provide('contractRead', contractRead);
provide('contractWrite', contractWrite);
provide('userAddress', userAddress);
provide('updateBalance', updateBalance)
</script>

<template>
  <div id="container">
    <h3>Account: {{ userAddress }}</h3>
    <h3>Balance: {{ balance }} ETH</h3>
    <router-view />
  </div>
</template>

<style scoped>
#container {
  display: flex;
  flex-direction: column;
  align-items: center;
}
</style>