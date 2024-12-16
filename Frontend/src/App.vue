<script setup>
import { ref, provide, onMounted } from 'vue';
import { ethers } from 'ethers';
import CoinFlipABI from './abis/CoinFlipABI.json';
import CreateGame from './components/CreateGame.vue';

const provider = ref(null);
const signer = ref(null);
const contractRead = ref(null);
const contractWrite = ref(null);
const userAddress = ref(null);
const balance = ref(0);

async function connectMetaMask() {
  if (window.ethereum && window.ethereum.isMetaMask) {
    try {
      const tempProvider = new ethers.BrowserProvider(window.ethereum);
      const tempSigner = await tempProvider.getSigner();

      provider.value = tempProvider;
      signer.value = tempSigner;

      userAddress.value = await tempSigner.getAddress();
      const unformattedBalance = await tempProvider.getBalance(userAddress.value);
      balance.value = ethers.formatEther(unformattedBalance);

      contractRead.value = new ethers.Contract(
        '0x5FbDB2315678afecb367f032d93F642f64180aa3',
        CoinFlipABI,
        tempProvider
      );

      contractWrite.value = new ethers.Contract(
        '0x5FbDB2315678afecb367f032d93F642f64180aa3',
        CoinFlipABI,
        tempSigner
      );

    } catch (error) {
      alert('The following error occurred: ' + error.message);
    }
  } else {
    alert('MetaMask is not installed');
  }
};

onMounted(() => {
  connectMetaMask();
});

provide('provider', provider);
provide('signer', signer);
provide('contractRead', contractRead);
provide('contractWrite', contractWrite);
provide('userAddress', userAddress);
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