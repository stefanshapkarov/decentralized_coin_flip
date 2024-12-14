<script setup>
import { ref, onMounted } from 'vue';
import { ethers } from 'ethers';

const isLoggedIn = ref(false);
const userAddress = ref('');
const balance = ref(0);

async function connectMetaMask() {
  let provider;
  let account;
  let unformattedBalance;
  if (window.ethereum && window.ethereum.isMetaMask) {
    provider = new ethers.BrowserProvider(window.ethereum);
    account = await provider.getSigner();
    
    userAddress.value = account.address;
    unformattedBalance = await provider.getBalance(userAddress.value);
    balance.value = ethers.formatEther(unformattedBalance);
    isLoggedIn.value = true;
  } else {
    alert('MetaMask is not installed');
  }
}
</script>

<template>
  <div id="container">
    <div v-if="isLoggedIn">
      <h3>Account: {{ userAddress }}</h3>
      <h3>Balance: {{ balance }}</h3>
    </div>
    <div v-else>
      <button @click="connectMetaMask">Connect to MetaMask</button>
    </div>
  </div>
</template>

<style scoped>
</style>