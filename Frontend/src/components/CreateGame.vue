<script setup>
import { ref, computed, inject } from 'vue';

const opponentAddress = ref('');
const betAmount = ref('');
const contract = inject('contract');

const userAddress = computed(() => {
  return sessionStorage.getItem('userAddress');
});

async function createGame() {
  console.log(opponentAddress.value, betAmount.value);
}
</script>

<template>
    <div id="form-container">
        <form @submit.prevent="createGame">
            <label for="opponentAddress">Opponent Address</label>
            <input type="text" v-model="opponentAddress" name="opponentAddress" id="opponentAddress" placeholder="0x..." />
            <label for="betAmount">Bet Amount</label>
            <input type="number" v-model="betAmount" name="betAmount" id="betAmount" placeholder="Bet Amount" />
            <button type="submit">Create Game</button>
        </form>
    </div>
</template>

<style scoped>
#form-container {
  display: flex;
  justify-content: center;
}

form {
  border: 1px solid gray;
  width: 300px;
  padding: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

input {
  text-align: center;
}

button {
  margin-top: 10px;
}
</style>