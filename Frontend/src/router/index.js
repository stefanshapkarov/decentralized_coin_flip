import { createRouter, createWebHistory } from 'vue-router';
import CreateGame from '../components/CreateGame.vue';
import PlayGame from '../components/PlayGame.vue';

const routes = [
  { path: '/', component: CreateGame },
  { path: '/play-game/:gameId', component: PlayGame, props: true }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;