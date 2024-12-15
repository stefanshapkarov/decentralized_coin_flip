<script setup>
import { ref, provide, onMounted } from 'vue';
import { ethers } from 'ethers';
import CreateGame from './components/CreateGame.vue';

const provider = ref(null);
const signer = ref(null);
const contract = ref(null);
const userAddress = ref(null);
const balance = ref(0);

async function initializeProvider() {
  let provider;
  let signer;
  let unformattedBalance;
  if (window.ethereum && window.ethereum.isMetaMask) {
    try {
      provider = new ethers.BrowserProvider(window.ethereum);
      signer = await provider.getSigner();
      provider.value = provider;
      signer.value = signer;
      userAddress.value = await signer.getAddress();
      sessionStorage.setItem('userAddress', userAddress.value);
      unformattedBalance = await provider.getBalance(userAddress.value);
      balance.value = ethers.formatEther(unformattedBalance);
      sessionStorage.setItem('balance', balance.value);

      contract.value = new ethers.Contract(
        '0x5FbDB2315678afecb367f032d93F642f64180aa3',
        getAbi('CoinFlip', 31337),
        provider
      );
    } catch (error) {
      alert('The following error occurred: ' + error.message);
    }
  } else {
    alert('MetaMask is not installed');
  }
};

function metaMaskListener() {
  window.ethereum.on('accountsChanged', async () => {
    await connectMetaMask();
  });
  window.ethereum.on('chainChanged', async () => {
    await connectMetaMask();
  });
}

onMounted(() => {
  if (userAddress.value == null && balance.value === 0) {
    userAddress.value = sessionStorage.getItem('userAddress');
    balance.value = sessionStorage.getItem('balance');
  }
  if (userAddress.value) {
    metaMaskListener();
  }
});

provide('provider', provider);
provide('signer', signer);
provide('contract', contract);
provide('userAddress', userAddress);
</script>

<template>
  <div id="container">
    <div v-if="userAddress">
      <h3>Account: {{ userAddress }}</h3>
      <h3>Balance: {{ balance }} ETH</h3>
      <router-view />
    </div>
    <div v-else>
      <button @click="initializeProvider">Connect MetaMask</button>
    </div>
  </div>
</template>

<style scoped>
#container {
  display: flex;
  flex-direction: column;
  align-items: center;
}
</style>