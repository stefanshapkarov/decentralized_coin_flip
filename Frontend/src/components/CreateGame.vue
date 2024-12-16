<script setup>
import { ref, inject } from 'vue';
import { ethers } from 'ethers';
import PulseLoader from 'vue-spinner/src/PulseLoader.vue';

const opponentAddress = ref('');
const betAmount = ref('');
const contractWrite = inject('contractWrite');
const inviteUrl = ref('');
const updateBalance = inject('updateBalance');
const buttonClicked = ref(false);

async function createGame() {
    try {
        buttonClicked.value = true;

        const transaction = await contractWrite.value.createGame(opponentAddress.value, { value: ethers.parseEther(betAmount.value.toString()) });
        const receipt = await transaction.wait();

        const gameCreatedEvent = receipt.logs.find(
            (log) => log.fragment && log.fragment.name === 'GameCreated'
        );

        if (gameCreatedEvent) {
            const { gameId, creator, opponent, betAmount } = gameCreatedEvent.args;

            inviteUrl.value = window.location.origin + `/play-game/${gameId}`;

            await updateBalance();
        }

        buttonClicked.value = false;
    } catch (error) {
        alert("The following error occurred: " + error.message);
    }
}
</script>

<template>
    <div id="form-container">
        <form @submit.prevent="createGame">
            <label for="opponentAddress">Opponent Address</label>
            <input type="text" v-model="opponentAddress" name="opponentAddress" id="opponentAddress" placeholder="0x..."
                required />
            <label for="betAmount">Bet Amount</label>
            <input type="number" v-model="betAmount" name="betAmount" id="betAmount" placeholder="Bet Amount"
                step="0.00001" min="0.00009" required />
            <button type="submit">Create Game</button>
        </form>

        <div v-if="buttonClicked" style="margin-top: 10px;">
            <PulseLoader />
        </div>
        <div v-else>
            <div v-if="inviteUrl">
                <p>Game created successfully! Invite your opponent to join the game by sharing the following URL:</p>
                <a :href="inviteUrl" target="_blank">{{ inviteUrl }}</a>
            </div>
        </div>
    </div>
</template>

<style scoped>
#form-container {
    display: flex;
    justify-content: center;
    flex-direction: column;
    align-items: center;
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