<script setup>
import { computed, inject, watchEffect, ref } from 'vue';
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
const isGameCancellable = computed(() => {
    if (!gameData.value || !currentBlockTimestamp.value) {
        return false;
    }
    
    const gameCreationTime = Number(gameData.value.createdAt);
    const currentTime = Number(currentBlockTimestamp.value);
    
    return (
        gameData.value.status == GameStatus.INITIALIZED &&
        currentTime >= (gameCreationTime + 86400)
    );
});
const userAddress = inject('userAddress');
const updateBalance = inject('updateBalance');
const isLoading = ref(true);
const gameData = ref(null);
const selectedSide = ref(null);

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
        await transaction.wait();
    } catch (error) {
        alert("Can't accept game: " + error.message);
    } finally {
        loadGame();
        updateBalance();
    }
}

async function cancelGame() {
    try {
        isLoading.value = true;

        const transaction = await contractWrite.value.cancelGame(gameId);
        await transaction.wait();
    } catch (error) {
        alert("Can't cancel the game: " + error.message);
    } finally {
        loadGame();
        updateBalance();
    }
}

async function flipCoin() {
    try {
        isLoading.value = true;
        
        if (!selectedSide.value) {
            alert("Please select a side first");
            return;
        }

        const pickingSide = parseInt(selectedSide.value);
        if (pickingSide !== 1 && pickingSide !== 2) {
            alert("Invalid coin side.");
            return;
        }

        const transaction = await contractWrite.value.flipCoin(gameId, pickingSide);
        await transaction.wait();
    } catch (error) {
        alert("Can't flip coin: " + error.message);
    } finally {
        loadGame();
        updateBalance();
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
                    <button v-if="isGameCancellable" @click="cancelGame">Cancel game</button>
                </div>
            </div>
            <div v-else-if="gameData.status == GameStatus.STARTED">
                <div v-if="isUserFlipper()">
                    <h4>Game started!</h4>
                    <h6>You are the flipper, flip the coin by pressing the button!</h6>
                    <form @submit.prevent="flipCoin" id="flip-coin">
                        <div id="radio-buttons">
                            <label for="heads">Heads</label>
                            <input 
                                type="radio" 
                                value="1" 
                                v-model="selectedSide"
                                id="heads" 
                                name="coinSide"
                            />
                            <label for="tails">Tails</label>
                            <input 
                                type="radio" 
                                value="2" 
                                v-model="selectedSide"
                                id="tails" 
                                name="coinSide"
                            />
                        </div>

                        <button type="submit" :disabled="!selectedSide">Flip Coin</button>
                    </form>
                </div>
                <div v-else>
                    <h4>Game started!</h4>
                    <p>Waiting for flipper to flip the coin...</p>
                </div>
            </div>
            <div v-else-if="gameData.status == GameStatus.FINISHED">
                <h4>Game finished!</h4>
                <p v-if="gameData.winner == userAddress" style="color: green">
                    <b>You are the winner!</b>
                </p>
                <p v-else style="color: red;">
                    <b>Sadly you lost, better luck next time!</b>
                </p>
            </div>
            <div v-else>
                <h3 style="color: yellow">Game has been cancelled.</h3>
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

#flip-coin {
    display: flex;
    flex-direction: column;
    gap: 5px;
}
</style>