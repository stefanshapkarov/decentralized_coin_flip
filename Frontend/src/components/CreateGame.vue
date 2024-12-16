<script setup>
import { ref, computed, inject, onUnmounted } from 'vue';
import { ethers } from 'ethers';

const opponentAddress = ref('');
const betAmount = ref('');
const contractRead = inject('contractRead');
const contractWrite = inject('contractWrite');
const inviteUrl = ref('');

async function createGame() {
    try {
        const transaction = await contractWrite.value.createGame(opponentAddress.value, { value: ethers.parseEther(betAmount.value.toString()) });
        await transaction.wait();

        console.log(transaction);
    } catch (error) {
        alert("The following error occurred: " + error.message);
    }
}
</script>

<template>
    <div id="form-container">
        <form @submit.prevent="createGame">
            <label for="opponentAddress">Opponent Address</label>
            <input type="text" v-model="opponentAddress" name="opponentAddress" id="opponentAddress"
                placeholder="0x..." />
            <label for="betAmount">Bet Amount</label>
            <input type="number" v-model="betAmount" name="betAmount" id="betAmount" placeholder="Bet Amount" />
            <button type="submit">Create Game</button>
        </form>

        <div v-if="inviteUrl"> 
            <p>Game created successfully! Invite your opponent to join the game by sharing the following URL:</p>
            <a :href="inviteUrl" target="_blank">{{ inviteUrl }}</a>
        </div>
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