<script setup>
import { onMounted, inject, watchEffect, ref } from 'vue';
import PulseLoader from 'vue-spinner/src/PulseLoader.vue';

const GameStatus = {
    INITIALIZED: 0,
    STARTED: 1,
    FINISHED: 2,
    CANCELLED: 3,
};

const props = defineProps({
    gameId: String,
});
const gameId = JSON.parse(props.gameId);
const contractRead = inject('contractRead');
const contractWrite = inject('contractWrite');
const currentBlockTimestamp = inject('currentBlockTimestamp');
const userAddress = inject('userAddress');
const isLoading = ref(true);
const gameData = ref(null);

async function loadGame() {
    try {
        const game = await contractRead.value.allGames(gameId);
        gameData.value = game;

        isLoading.value = false;
    } catch (error) {
        alert('Error loading the game: ' + error.message);
    }
}

async function acceptGame() {
    try {
        isLoading.value = true;

        const transaction = await contractWrite.value.acceptGame(gameId, { value: gameData.value.betAmount });
        const receipt = await transaction.wait();

        const gameAcceptedEvent = receipt.logs.find(
            (log) => log.fragment && log.fragment.name === 'GameAccepted'
        );

        if (gameAcceptedEvent) {
            const { gameId, pickingSide } = gameAcceptedEvent.args;
            console.log("Game with id: " + gameId + " is accepted, picking side: " + pickingSide);
        }

        loadGame();
    } catch (error) {
        alert("Can't accept game: " + error.message);
    }
}

function isUserOpponent() {
    return userAddress.value === gameData.value.opponent;
}

function isUserFlipper() {
    const flipper = gameData.value.pickingSide;
    if (flipper == 1) {
        if (userAddress.value === gameData.value.initializer) {
            return true;
        } else {
            return false;
        }
    } else if (flipper == 2) {
        if (userAddress.value === gameData.value.opponent) {
            return true;
        } else {
            return false;
        }
    } else {
        alert("Invalid game status.")
    }
}

watchEffect(async () => {
    if (contractRead.value && contractWrite.value) {
        await loadGame();
    }
});
</script>

<template>
    <div class="game-container">
        <div v-if="isLoading">
            <PulseLoader />
        </div>
        <div v-else>
            <div v-if="gameData.status == GameStatus.INITIALIZED">
                <div v-if="isUserOpponent()">
                    <button @click="acceptGame">Accept game</button>
                </div>
                <div v-else>
                    <p>Waiting for opponent to accept the game...</p>
                </div>
            </div>
            <div v-else-if="gameData.status == GameStatus.STARTED">
                <div v-if="isUserFlipper()">
                    <button>Flip Coin</button>
                </div>
                <div v-else>
                    <p>Waiting for flipper to flip the coin...</p>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>
.game-container {
    border: 1px solid grey;
    padding: 10px;
    width: 350px;
}
</style>