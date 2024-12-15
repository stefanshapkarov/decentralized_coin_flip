<script setup>
import { useRoute } from 'vue-router';

const route = useRoute();
const props = defineProps({
    gameId: String,
});

const gameId = JSON.parse(props.gameId);

</script>

<template>
    <h1>Play Game</h1>
    <h2>Game ID: {{ gameId }}</h2>
</template>

<style scoped>
</style>